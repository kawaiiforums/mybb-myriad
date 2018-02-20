#![feature(plugin)]
#![plugin(rocket_codegen)]
#![feature(type_ascription)]

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate postgres;
extern crate envy;
extern crate rocket;

mod search;
mod database;

fn main() {
    let pg_config = match envy::from_env::<database::PostgresConnectionConfig>() {
        Ok(conf) => conf,
        Err(error) => panic!("Error reading Postgres configuration: {:#?}", error)
    };

    mount_paths(pg_config);
}

fn mount_paths(pg_config: database::PostgresConnectionConfig) {
  rocket::ignite()
    .mount("/search", routes![search::users])
    .manage(pg_config)
    .launch();
}