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
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('ppt_host.log')
    ]
)

class PPTHostController:
    def __init__(self):
        self.host = '0.0.0.0'  # Listen on all available interfaces
        self.port = 3000
        self.server = None
        self.clients = []
        self.is_running = False
        self.lock = threading.Lock()
        
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
        logging.info("PPT Host Controller initialized")

    def get_local_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            logging.info(f"Local IP: {ip}")
            return ip
        except Exception as e:
            logging.error(f"Error getting local IP: {e}")
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
            logging.info("Server started successfully")
            
            threading.Thread(target=self.accept_clients, daemon=True).start()
        except Exception as e:
            self.status_var.set(f"Error: {str(e)}")
            self.is_running = False
            logging.error(f"Error starting server: {e}")

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
        logging.info("Server stopped")

    def toggle_server(self):
        if not self.is_running:
            self.start_server()
        else:
            self.stop_server()

    def accept_clients(self):
        while self.is_running:
            try:
                client, address = self.server.accept()
                logging.info(f"New connection from {address}")
                with self.lock:
                    self.clients.append(client)
                    self.clients_var.set(f"Connected Clients: {len(self.clients)}")
                threading.Thread(target=self.handle_client, args=(client, address), daemon=True).start()
            except Exception as e:
                if self.is_running:
                    logging.error(f"Error accepting client: {e}")
                break

    def handle_client(self, client, address):
        while self.is_running:
            try:
                data = client.recv(1024).decode('utf-8')
                if not data:
                    break
                
                logging.info(f"Received command from {address}: {data}")
                
                # Handle commands
                if data == "START":
                    pyautogui.press('f5')
                    logging.info("Executed START command (F5)")
                elif data == "NEXT":
                    pyautogui.press('right')
                    logging.info("Executed NEXT command (Right Arrow)")
                elif data == "PREV":
                    pyautogui.press('left')
                    logging.info("Executed PREV command (Left Arrow)")
                elif data == "END":
                    pyautogui.press('esc')
                    logging.info("Executed END command (Esc)")
                
            except Exception as e:
                logging.error(f"Error handling client {address}: {e}")
                break
        
        with self.lock:
            if client in self.clients:
                self.clients.remove(client)
                self.clients_var.set(f"Connected Clients: {len(self.clients)}")
        try:
            client.close()
            logging.info(f"Client {address} disconnected")
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