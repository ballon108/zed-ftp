use anyhow::{anyhow, Result};
use async_trait::async_trait;
use ftp::FtpStream;
use log::{debug, info};
use serde::{Deserialize, Serialize};
use std::{
    fs::File,
    io::{Read, Write},
    path::Path,
    sync::Arc,
};
use tokio::sync::Mutex;

// Mock ZED extension API for development purposes
// In a real implementation, you would use the actual zed_extension_api crate
pub struct ExtensionContext;

impl ExtensionContext {
    pub fn register_command(
        &self,
        _name: &str,
        _description: &str,
        _callback: Box<dyn FnMut() -> Result<()> + Send + Sync>,
    ) -> Result<()> {
        Ok(())
    }
}

#[async_trait::async_trait]
pub trait Extension: Send + Sync {
    async fn activate(&self, cx: &ExtensionContext) -> Result<()>;
    async fn deactivate(&self, cx: &ExtensionContext) -> Result<()>;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FtpConfig {
    host: String,
    port: u16,
    username: String,
    password: String,
    initial_directory: Option<String>,
}

#[derive(Debug)]
pub struct FtpConnection {
    config: FtpConfig,
    ftp_stream: Mutex<Option<FtpStream>>,
}

impl FtpConnection {
    pub fn new(config: FtpConfig) -> Self {
        Self {
            config,
            ftp_stream: Mutex::new(None),
        }
    }

    pub async fn connect(&self) -> Result<()> {
        let mut stream_guard = self.ftp_stream.lock().await;

        // If already connected, return
        if stream_guard.is_some() {
            return Ok(());
        }

        // Create a new connection
        let addr = format!("{}:{}", self.config.host, self.config.port);
        debug!("Connecting to FTP server at {}", addr);

        // Note: FtpStream currently uses blocking I/O
        // For a production plugin, you'd want to use tokio::spawn or similar to avoid blocking
        let mut ftp_stream = FtpStream::connect(&addr)
            .map_err(|e| anyhow!("Failed to connect to FTP server: {}", e))?;

        // Login
        ftp_stream
            .login(&self.config.username, &self.config.password)
            .map_err(|e| anyhow!("Failed to login to FTP server: {}", e))?;

        // Set initial directory if specified
        if let Some(dir) = &self.config.initial_directory {
            ftp_stream
                .cwd(dir)
                .map_err(|e| anyhow!("Failed to change to initial directory: {}", e))?;
        }

        info!("Successfully connected to FTP server");
        *stream_guard = Some(ftp_stream);
        Ok(())
    }

    pub async fn disconnect(&self) -> Result<()> {
        let mut stream_guard = self.ftp_stream.lock().await;
        if let Some(mut stream) = stream_guard.take() {
            stream
                .quit()
                .map_err(|e| anyhow!("Failed to disconnect from FTP server: {}", e))?;
            info!("Disconnected from FTP server");
        }
        Ok(())
    }

    pub async fn list_current_directory(&self) -> Result<Vec<String>> {
        let mut stream_guard = self.ftp_stream.lock().await;
        if stream_guard.is_none() {
            return Err(anyhow!("Not connected to FTP server"));
        }

        let stream = stream_guard.as_mut().unwrap();
        let list = stream
            .list(None)
            .map_err(|e| anyhow!("Failed to list directory: {}", e))?;

        // The ftp crate's list() returns entries with filename as a String
        Ok(list)
    }

    pub async fn download_file(&self, remote_path: &str, local_path: &Path) -> Result<()> {
        let mut stream_guard = self.ftp_stream.lock().await;
        if stream_guard.is_none() {
            return Err(anyhow!("Not connected to FTP server"));
        }

        let stream = stream_guard.as_mut().unwrap();
        let remote_file = stream
            .simple_retr(remote_path)
            .map_err(|e| anyhow!("Failed to download file: {}", e))?;

        let mut file = File::create(local_path)
            .map_err(|e| anyhow!("Failed to create local file: {}", e))?;
        file.write_all(&remote_file.into_inner())
            .map_err(|e| anyhow!("Failed to write to local file: {}", e))?;

        Ok(())
    }

    pub async fn upload_file(&self, local_path: &Path, remote_path: &str) -> Result<()> {
        let mut stream_guard = self.ftp_stream.lock().await;
        if stream_guard.is_none() {
            return Err(anyhow!("Not connected to FTP server"));
        }

        let stream = stream_guard.as_mut().unwrap();
        let mut file = File::open(local_path)
            .map_err(|e| anyhow!("Failed to open local file: {}", e))?;
        let mut contents = Vec::new();
        file.read_to_end(&mut contents)
            .map_err(|e| anyhow!("Failed to read local file: {}", e))?;

        stream
            .put(remote_path, &mut contents.as_slice())
            .map_err(|e| anyhow!("Failed to upload file: {}", e))?;

        Ok(())
    }
    
    pub async fn delete_file(&self, remote_path: &str) -> Result<()> {
        let mut stream_guard = self.ftp_stream.lock().await;
        if stream_guard.is_none() {
            return Err(anyhow!("Not connected to FTP server"));
        }

        let stream = stream_guard.as_mut().unwrap();
        stream
            .rm(remote_path)
            .map_err(|e| anyhow!("Failed to delete remote file: {}", e))?;

        Ok(())
    }
}

struct FtpExtension {
    connection: Arc<FtpConnection>,
}

impl FtpExtension {
    fn new(_ctx: &ExtensionContext) -> Result<Self> {
        // In a real implementation, you'd get the config from the extension settings
        // This is just a placeholder example
        let config = FtpConfig {
            host: "ftp.example.com".to_string(),
            port: 21,
            username: "anonymous".to_string(),
            password: "anonymous@".to_string(),
            initial_directory: None,
        };

        Ok(Self {
            connection: Arc::new(FtpConnection::new(config)),
        })
    }
}

#[async_trait]
impl Extension for FtpExtension {
    async fn activate(&self, cx: &ExtensionContext) -> Result<()> {
        info!("Activating FTP extension");
        
        // Register commands
        cx.register_command(
            "ftp.connect",
            "Connect to FTP server",
            Box::new(move || {
                // In a real implementation, this would properly handle async operations
                // For now, we're just creating a simplified mock
                info!("Would connect to FTP server");
                Ok(())
            }),
        )?;

        cx.register_command(
            "ftp.disconnect",
            "Disconnect from FTP server",
            Box::new(move || {
                info!("Would disconnect from FTP server");
                Ok(())
            }),
        )?;

        cx.register_command(
            "ftp.list",
            "List current directory on FTP server",
            Box::new(move || {
                info!("Would list files from FTP server");
                Ok(())
            }),
        )?;

        Ok(())
    }

    async fn deactivate(&self, _: &ExtensionContext) -> Result<()> {
        info!("Deactivating FTP extension");
        self.connection.disconnect().await?;
        Ok(())
    }
}

// This function would be used in actual plugin integration
// #[no_mangle]
pub fn init_extension(ctx: &ExtensionContext) -> Result<Box<dyn Extension>> {
    let extension = FtpExtension::new(ctx)?;
    Ok(Box::new(extension))
}