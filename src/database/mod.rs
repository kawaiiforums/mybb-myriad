#[derive(Deserialize, Debug)]
pub struct PostgresConnectionConfig {
	#[serde(default = "default_postgres_host")]
	postgres_host: String,
	#[serde(default = "default_postgres_port")]
	postgres_port: u16,
	#[serde(default = "default_postgres_user")]
	postgres_user: String,
	#[serde(default = "default_postgres_password")]
	postgres_password: String,
	postgres_db: String
}

fn default_postgres_host() -> String {
	"localhost".to_string()
}

fn default_postgres_port() -> u16 {
	5432
}

fn default_postgres_user() -> String {
	"postgres".to_string()
}

fn default_postgres_password() -> String {
	"postgres".to_string()
}

impl PostgresConnectionConfig {
	pub fn connection_string(&self) -> String {
		format!(
			"postgres://{}:{}@{}:{}/{}",
			self.postgres_user,
			self.postgres_password, 
			self.postgres_host, 
			self.postgres_port, 
			self.postgres_db
		)
	}
}