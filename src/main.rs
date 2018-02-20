#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate postgres;
extern crate envy;

use postgres::{Connection, TlsMode};

#[derive(Deserialize, Debug)]
struct postgres_config {
  postgres_host: String,
  postgres_port: u16,
  postgres_db: String,
  postgres_user: String,
  postgres_password: String,
}

fn main() {
    let pg_config = match envy::from_env::<postgres_config>() {
        Ok(postgres_config) => postgres_config,
        Err(error) => panic!("Error reading Postgres configuration: {:#?}", error)
    };

    let connection_string = format!("postgres://{}:{}@{}:{}/{}", pg_config.postgres_user,
        pg_config.postgres_password, pg_config.postgres_host, pg_config.postgres_port, 
        pg_config.postgres_db);

    let conn = match Connection::connect(connection_string, TlsMode::None) {
        Ok(c) => c,
        Err(e) => panic!("Error connecting to Postgres server: {:#?}", e)
    };
}
