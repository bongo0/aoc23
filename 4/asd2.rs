use std::fs;


fn main(){
    let input = fs::read_to_string("input").expect("failed to read input");


    let lines = input.lines();

    let mut score_sum:i64 = 0;

    let mut cards : Vec<i32> = vec![1; input.lines().count()];

    for (i,l) in lines.enumerate() {
        //println!("{i}: {l}");
        
        let a = l.split_once(":").expect("parse : fail").1;
        let w_d = a.split_once("|").expect("parse | fail");
        
        let winning: Vec<i32> = w_d.0.split_whitespace().map(|x| x.parse::<i32>().unwrap()).collect();
        let draw: Vec<i32> = w_d.1.split_whitespace().map(|x| x.parse::<i32>().unwrap()).collect();
        
        let mut score:i64 = 0;
        let mut n_wins:usize = 0;
        for d in draw{
            if winning.contains(&d) {
                n_wins+=1;
                if score==0 {score=1;}
                else {score*=2;}
            }
        }
        for _n in 1..=cards[i]{
            //println!("n={n}");
            let mut m:usize=0;
            while m < n_wins {
                m+=1;
                cards[i+m] += 1;
            }
        }

        score_sum+=score;
        println!("{i} : {n_wins}")

    }
    for (i,n) in cards.iter().enumerate(){
        println!("{i} {n}");
    }
    println!("score_sum: {score_sum}");
    println!("n_cards: {}",cards.iter().sum::<i32>());


}