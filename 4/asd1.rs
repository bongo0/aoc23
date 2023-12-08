use std::fs;


fn main(){
    let input = fs::read_to_string("input").expect("failed to read input");


    let lines = input.lines();

    let mut score_sum:i64 = 0;

    for (i,l) in lines.enumerate() {
        //println!("{i}: {l}");
        
        let a = l.split_once(":").expect("parse : fail").1;
        let w_d = a.split_once("|").expect("parse | fail");
        
        let winning: Vec<i32> = w_d.0.split_whitespace().map(|x| x.parse::<i32>().unwrap()).collect();
        let draw: Vec<i32> = w_d.1.split_whitespace().map(|x| x.parse::<i32>().unwrap()).collect();
        
        let mut score:i64 = 0;

        for d in draw{
            if winning.contains(&d) {
                if score==0 {score=1;}
                else {score*=2;}
            }
        }

        score_sum+=score;
        println!("{score} : {score_sum}")

    }

    println!("score_sum: {score_sum}")

}