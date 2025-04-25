import socket
import threading
import pyautogui
import json
from tkinter import *
from tkinter import ttk
import sys
from PIL import Image, ImageTk
import os
import time

class PPTHostController:
    def __init__(self):
        self.host = '0.0.0.0'  # Listen on all available interfaces
        self.port = 3000
        self.server = None
        self.clients = []
        self.is_running = False
        self.lock = threading.Lock()  # Add lock for thread safety
        
        # Create GUI
        self.root = Tk()
        self.root.title("PPT Host Controller")
        self.root.geometry("300x200")
        
        # Status label
        self.status_var = StringVar(value="Server Stopped")
        ttk.Label(self.root, textvariable=self.status_var).pack(pady=10)
        
        # IP Address display
        self.ip_var = StringVar(value=f"IP: {self.get_local_ip()}")
        ttk.Label(self.root, textvariable=self.ip_var).pack(pady=5)
        
        # Start/Stop button
        self.toggle_button = ttk.Button(self.root, text="Start Server", command=self.toggle_server)
        self.toggle_button.pack(pady=20)
        
        # Connected clients label
        self.clients_var = StringVar(value="Connected Clients: 0")
        ttk.Label(self.root, textvariable=self.clients_var).pack(pady=5)
        
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def get_local_ip(self):
        try:
            # Create a temporary socket to get local IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception as e:
            print(f"Error getting local IP: {e}")
            return "127.0.0.1"

    def start_server(self):
        try:
            self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server.bind((self.host, self.port))
            self.server.listen(5)
            self.is_running = True
            self.status_var.set("Server Running")
            self.toggle_button.config(text="Stop Server")
            
            # Start accepting clients in a separate thread
            threading.Thread(target=self.accept_clients, daemon=True).start()
        except Exception as e:
            self.status_var.set(f"Error: {str(e)}")
            self.is_running = False

    def stop_server(self):
        self.is_running = False
        if self.server:
            try:
                self.server.close()
            except:
                pass
        with self.lock:
            for client in self.clients:
                try:
                    client.close()
                except:
                    pass
            self.clients = []
        self.status_var.set("Server Stopped")
        self.toggle_button.config(text="Start Server")
        self.clients_var.set("Connected Clients: 0")

    def toggle_server(self):
        if not self.is_running:
            self.start_server()
        else:
            self.stop_server()

    def accept_clients(self):
        while self.is_running:
            try:
                client, address = self.server.accept()
                with self.lock:
                    self.clients.append(client)
                    self.clients_var.set(f"Connected Clients: {len(self.clients)}")
                threading.Thread(target=self.handle_client, args=(client,), daemon=True).start()
            except Exception as e:
                if self.is_running:  # Only print error if server is still running
                    print(f"Error accepting client: {e}")
                break

    def handle_client(self, client):
        while self.is_running:
            try:
                data = client.recv(1024).decode('utf-8')
                if not data:
                    break
                
                # Handle commands
                if data == "START":
                    pyautogui.press('f5')
                elif data == "NEXT":
                    pyautogui.press('right')
                elif data == "PREV":
                    pyautogui.press('left')
                elif data == "END":
                    pyautogui.press('esc')
                
            except Exception as e:
                print(f"Error handling client: {e}")
                break
        
        with self.lock:
            if client in self.clients:
                self.clients.remove(client)
                self.clients_var.set(f"Connected Clients: {len(self.clients)}")
        try:
            client.close()
        except:
            pass

    def on_closing(self):
        self.stop_server()
        self.root.quit()
        sys.exit(0)

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = PPTHostController()
    app.run() 