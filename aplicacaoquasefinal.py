import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import pyodbc

class DatabaseApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Aplicação de Banco de Dados")

        self.conn = None
        self.cursor = None

        self.default_connection()
        self.create_initial_screen()

    def default_connection(self):
        try:
            # Configuração da conexão com o banco de dados
            ip = "192.168.100.14"  # Endereço IP do servidor
            user = "User_BD_PL3_05"  # Nome de usuário
            password = "diubi:2024!BD!PL3_05"  # Senha
            database = "BD_PL3_05"  # Nome do banco de dados

            self.conn = pyodbc.connect(
                f"DRIVER={{SQL Server}};SERVER={ip};DATABASE={database};UID={user};PWD={password}")
            self.cursor = self.conn.cursor()
            messagebox.showinfo("Sucesso", "Conexão com o banco de dados bem-sucedida!")
        except Exception as e:
            messagebox.showerror("Erro na Conexão", f"Erro ao conectar ao banco de dados: {e}")

    def create_initial_screen(self):
        frame = tk.Frame(self.root)
        frame.pack(pady=20, padx=20)

        # Botões para a tela inicial
        buttons = [
            ("Adicionar Dados", self.add_data),
            ("Atualizar Dados", self.update_data),
            ("Apagar Dados", self.delete_data),
            ("Visualizar Dados", self.view_data),
            ("Query Genérica", self.generic_query)
        ]
        for i, (text, command) in enumerate(buttons):
            button = tk.Button(frame, text=text, command=command, width=20)
            button.grid(row=i, column=0, pady=5)

    def add_data(self):
        if not self.cursor:
            messagebox.showwarning("Aviso", "Conecte-se ao banco de dados primeiro.")
            return

        try:
            self.cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
            tables = [row.TABLE_NAME for row in self.cursor.fetchall()]

            add_window = tk.Toplevel(self.root)
            add_window.title("Adicionar Dados")

            # Combo box para selecionar a tabela
            tk.Label(add_window, text="Escolha uma tabela:").pack(pady=5)
            table_dropdown = ttk.Combobox(add_window, values=tables)
            table_dropdown.pack(pady=5)

            fields_frame = tk.Frame(add_window)
            fields_frame.pack(pady=10)

            def load_table_fields():
                for widget in fields_frame.winfo_children():
                    widget.destroy()

                table = table_dropdown.get()
                if table:
                    try:
                        self.cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table}'")
                        columns = [row.COLUMN_NAME for row in self.cursor.fetchall()]
                        self.fields_entries = {}

                        for col in columns:
                            tk.Label(fields_frame, text=f"{col}:").pack(anchor="w")
                            entry = tk.Entry(fields_frame, width=50)
                            entry.pack(anchor="w", pady=2)
                            self.fields_entries[col] = entry

                        insert_button["state"] = "normal"
                    except Exception as e:
                        messagebox.showerror("Erro", f"Erro ao obter colunas: {e}")

            table_dropdown.bind("<<ComboboxSelected>>", lambda e: load_table_fields())
            insert_button = tk.Button(add_window, text="Inserir Dados", state="disabled", command=lambda: self.insert_data(table_dropdown.get()))
            insert_button.pack(pady=10)

        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao obter tabelas: {e}")

    def insert_data(self, table):
        if table and self.fields_entries:
            try:
                columns = ", ".join(self.fields_entries.keys())
                values = ", ".join([f"'{entry.get()}'" for entry in self.fields_entries.values()])
                self.cursor.execute(f"INSERT INTO {table} ({columns}) VALUES ({values})")
                self.conn.commit()
                messagebox.showinfo("Sucesso", "Dados adicionados com sucesso!")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao adicionar dados: {e}")

    def update_data(self):
        if not self.cursor:
            messagebox.showwarning("Aviso", "Conecte-se ao banco de dados primeiro.")
            return

        try:
            self.cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
            tables = [row.TABLE_NAME for row in self.cursor.fetchall()]

            update_window = tk.Toplevel(self.root)
            update_window.title("Atualizar Dados")

            tk.Label(update_window, text="Escolha uma tabela:").pack(pady=5)
            table_dropdown = ttk.Combobox(update_window, values=tables)
            table_dropdown.pack(pady=5)

            data_frame = tk.Frame(update_window)
            data_frame.pack(pady=10)

            def load_table_data():
                for widget in data_frame.winfo_children():
                    widget.destroy()

                table = table_dropdown.get()
                if table:
                    try:
                        self.cursor.execute(f"SELECT * FROM {table}")
                        columns = [desc[0] for desc in self.cursor.description]
                        rows = self.cursor.fetchall()

                        tree = ttk.Treeview(data_frame, height=15)
                        tree.pack(pady=5, fill=tk.BOTH, expand=True)
                        tree["columns"] = columns
                        tree["show"] = "headings"

                        for col in columns:
                            tree.heading(col, text=col)
                            tree.column(col, anchor="w")

                        for row in rows:
                            tree.insert("", "end", values=row)

                        def edit_selected():
                            selected_item = tree.selection()
                            if selected_item:
                                item_values = tree.item(selected_item, "values")
                                edit_window = tk.Toplevel(update_window)
                                edit_window.title("Editar Dados")
                                edit_entries = {}

                                for col, value in zip(columns, item_values):
                                    tk.Label(edit_window, text=f"{col}:").pack(anchor="w")
                                    entry = tk.Entry(edit_window, width=50)
                                    entry.insert(0, value)
                                    entry.pack(anchor="w", pady=2)
                                    edit_entries[col] = entry

                                def confirm_update():
                                    set_clause = ", ".join([f"{col}='{edit_entries[col].get()}'" for col in columns])
                                    condition = " AND ".join([f"{col}='{value}'" for col, value in zip(columns, item_values)])
                                    try:
                                        self.cursor.execute(f"UPDATE {table} SET {set_clause} WHERE {condition}")
                                        self.conn.commit()
                                        messagebox.showinfo("Sucesso", "Dados atualizados com sucesso!")
                                        edit_window.destroy()
                                        load_table_data()
                                    except Exception as e:
                                        messagebox.showerror("Erro", f"Erro ao atualizar dados: {e}")

                                tk.Button(edit_window, text="Confirmar Alterações", command=confirm_update).pack(pady=10)

                        tk.Button(data_frame, text="Editar Selecionado", command=edit_selected).pack(pady=10)

                    except Exception as e:
                        messagebox.showerror("Erro", f"Erro ao obter dados: {e}")

            table_dropdown.bind("<<ComboboxSelected>>", lambda e: load_table_data())

        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao obter tabelas: {e}")

    def delete_data(self):
        if not self.cursor:
            messagebox.showwarning("Aviso", "Conecte-se ao banco de dados primeiro.")
            return

        try:
            self.cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
            tables = [row.TABLE_NAME for row in self.cursor.fetchall()]

            delete_window = tk.Toplevel(self.root)
            delete_window.title("Apagar Dados")

            tk.Label(delete_window, text="Escolha uma tabela:").pack(pady=5)
            table_dropdown = ttk.Combobox(delete_window, values=tables)
            table_dropdown.pack(pady=5)

            data_frame = tk.Frame(delete_window)
            data_frame.pack(pady=10)

            def load_table_data():
                for widget in data_frame.winfo_children():
                    widget.destroy()

                table = table_dropdown.get()
                if table:
                    try:
                        self.cursor.execute(f"SELECT * FROM {table}")
                        columns = [desc[0] for desc in self.cursor.description]
                        rows = self.cursor.fetchall()

                        tree = ttk.Treeview(data_frame, height=15, selectmode="extended")
                        tree.pack(pady=5, fill=tk.BOTH, expand=True)
                        tree["columns"] = columns
                        tree["show"] = "headings"

                        for col in columns:
                            tree.heading(col, text=col)
                            tree.column(col, anchor="w")

                        for row in rows:
                            tree.insert("", "end", values=row)

                        def delete_selected():
                            selected_items = tree.selection()
                            if selected_items:
                                confirm = messagebox.askyesno("Confirmar Exclusão", "Tem certeza que deseja excluir os itens selecionados?")
                                if confirm:
                                    for item in selected_items:
                                        values = tree.item(item, "values")
                                        condition = " AND ".join([f"{col}='{value}'" for col, value in zip(columns, values)])
                                        try:
                                            self.cursor.execute(f"DELETE FROM {table} WHERE {condition}")
                                        except Exception as e:
                                            messagebox.showerror("Erro", f"Erro ao excluir: {e}")
                                    self.conn.commit()
                                    messagebox.showinfo("Sucesso", "Itens excluídos com sucesso!")
                                    load_table_data()

                        tk.Button(data_frame, text="Excluir Selecionados", command=delete_selected).pack(pady=10)

                    except Exception as e:
                        messagebox.showerror("Erro", f"Erro ao obter dados: {e}")

            table_dropdown.bind("<<ComboboxSelected>>", lambda e: load_table_data())

        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao obter tabelas: {e}")

    def view_data(self):
        if not self.cursor:
            messagebox.showwarning("Aviso", "Conecte-se ao banco de dados primeiro.")
            return

        try:
            self.cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
            tables = [row.TABLE_NAME for row in self.cursor.fetchall()]

            view_window = tk.Toplevel(self.root)
            view_window.title("Visualizar Dados")

            tk.Label(view_window, text="Escolha uma tabela:").pack(pady=5)
            table_dropdown = ttk.Combobox(view_window, values=tables)
            table_dropdown.pack(pady=5)

            tree = ttk.Treeview(view_window, height=15)
            tree.pack(pady=5, fill=tk.BOTH, expand=True)

            def fetch_table_data():
                selected_table = table_dropdown.get()
                if selected_table:
                    try:
                        self.cursor.execute(f"SELECT * FROM {selected_table}")
                        columns = [desc[0] for desc in self.cursor.description]
                        rows = self.cursor.fetchall()

                        # Limpar antes de preencher
                        for i in tree.get_children():
                            tree.delete(i)

                        tree["columns"] = columns
                        tree["show"] = "headings"

                        for col in columns:
                            tree.heading(col, text=col)
                            tree.column(col, anchor="w")

                        for row in rows:
                            tree.insert("", "end", values=row)

                    except Exception as e:
                        messagebox.showerror("Erro", f"Erro ao buscar dados: {e}")

            tk.Button(view_window, text="Visualizar", command=fetch_table_data).pack(pady=10)

        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao obter tabelas: {e}")

    def generic_query(self):
        query = simpledialog.askstring("Query SQL", "Digite sua query SQL:")
        if query:
            try:
                self.cursor.execute(query)
                rows = self.cursor.fetchall()
                columns = [desc[0] for desc in self.cursor.description]

                result_window = tk.Toplevel(self.root)
                result_window.title("Resultado da Query")

                tree = ttk.Treeview(result_window, height=15)
                tree.pack(pady=5, fill=tk.BOTH, expand=True)

                tree["columns"] = columns
                tree["show"] = "headings"

                for col in columns:
                    tree.heading(col, text=col)
                    tree.column(col, anchor="w")

                for row in rows:
                    tree.insert("", "end", values=row)

            except Exception as e:
                messagebox.showerror("Erro", f"Erro na consulta: {e}")


if __name__ == "__main__":
    root = tk.Tk()
    app = DatabaseApp(root)
    root.mainloop()
