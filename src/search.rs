use postgres::{Connection, TlsMode};
use rocket::State;

use database;

#[get("/users/<username>")]
pub fn users(state: State<database::PostgresConnectionConfig>, username: String) -> String {
    let connection_string = &state.connection_string();

    let search_term = format!("%{}%", username);

    if username.len() < 3 || username.len() > 16 {
        return("nope").to_string();
    }

    match Connection::connect(connection_string.to_string(), TlsMode::None) {
        Ok(c) => {
            match c.query(
                "SELECT uid AS u, username AS n 
                FROM mybb_users 
                WHERE username LIKE $1
                ORDER BY postnum DESC, lastactive DESC, username LIMIT 15",
                &[
                    &search_term
                ]
            ) {
                Ok(rows) => {
                    let mut users_string = String::new();
                    let mut num_users = 0;

                    for row in rows.iter() {
                        let user_id: i32 = row.get("u");
                        let user_name: String = row.get("n");

                        users_string.push_str(&user_id.to_string());
                        users_string.push_str(&user_name);
                        users_string.push_str(", ");

                        num_users += 1;
                    }

                    if num_users > 0 {
                        let users_string_len = users_string.len();
                        users_string.truncate(users_string_len - 2)
                    }

                    users_string
                },
                Err(e) => {
                    format!("Error running DB query: {:#?}", e)
                }
            }
        },
        Err(e) => format!("Error connecting to DB: {:#?}", e)
    }

    
}