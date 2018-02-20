#![feature(plugin)]
#![plugin(rocket_codegen)]
#![feature(type_ascription)]
#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate postgres;
extern crate envy;
extern crate rocket;

use postgres::{Connection, TlsMode};
use rocket::State;

mod search;

#[derive(Deserialize, Debug)]
struct postgres_config {
  postgres_host: String,
  postgres_port: u16,
  postgres_db: String,
  postgres_user: String,
  postgres_password: String,
}

pub struct ConnectionHolder(String);

fn main() {
    let pg_config = match envy::from_env::<postgres_config>() {
        Ok(postgres_config) => postgres_config,
        Err(error) => panic!("Error reading Postgres configuration: {:#?}", error)
    };

    let connection_string = format!("postgres://{}:{}@{}:{}/{}", pg_config.postgres_user,
        pg_config.postgres_password, pg_config.postgres_host, pg_config.postgres_port, 
        pg_config.postgres_db);

    mount_paths(connection_string);
}

fn mount_paths(conf: String) {
  rocket::ignite()
    .mount("/search", routes![search::users])
    .manage(ConnectionHolder(conf))
    .launch();
}