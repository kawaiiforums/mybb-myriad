use postgres::{Connection, TlsMode};
use rocket::State;
use ConnectionHolder;

#[get("/users/<username>")]
pub fn users(state: State<ConnectionHolder>, username: String) -> String {
    let c = format!("{}", state.0);
    let conn = match Connection::connect(c, TlsMode::None) {
        Ok(c) => c,
        Err(e) => panic!("Error connecting to Postgres server: {:#?}", e)
    };

    let query = conn.execute("SELECT uid AS u, username AS n FROM mybb_users WHERE username like {} ORDER BY postnum DESC, lastactive DESC, username LIMIT 15",
                             &[username.as_str()]).unwrap();
    format!("{}", query)
}