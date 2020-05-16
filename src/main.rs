extern crate zksnark;


use actix_web::{get, web, App, HttpServer, Responder};


use zksnark::groth16;
use zksnark::groth16::{QAP};
use zksnark::groth16::circuit::{ASTParser, TryParse};
use zksnark::groth16::fr::FrLocal;
use zksnark::groth16::coefficient_poly::CoefficientPoly;


#[get("/{id}/{name}/index")]
async fn index(info: web::Path<(u32, String)>) -> impl Responder {

    // x = 4ab + c + 6
    let code = &*::std::fs::read_to_string("raw/test.zk").unwrap();
    let qap: QAP<CoefficientPoly<FrLocal>> =
        ASTParser::try_parse(code)
            .unwrap()
            .into();

    // The assignments are the inputs to the circuit in the order they
    // appear in the file
    let assignments = &[
        3.into(), // a
        2.into(), // b
        4.into(), // c
    ];
    let weights = groth16::weights(code, assignments).unwrap();
    let (sigmag1, sigmag2) = groth16::setup(&qap);
    let proof = groth16::prove(&qap, (&sigmag1, &sigmag2), &weights);
    println!("{}",groth16::verify(&qap,(sigmag1, sigmag2), &vec![FrLocal::from(2), FrLocal::from(34)], proof));



    //assert!();





    format!("Hello {}! id:{}", info.1, info.0)
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().service(index))
        .bind("127.0.0.1:8080")?
        .run()
        .await
}
