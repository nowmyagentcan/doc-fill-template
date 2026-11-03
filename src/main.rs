fn main() {
    match std::env::args().nth(1).as_deref() {
        Some("--version" | "-V") => println!("doc-fill-template {}", env!("CARGO_PKG_VERSION")),
        _ => {
            eprintln!("Usage: doc-fill-template --version");
            std::process::exit(2);
        }
    }
}
