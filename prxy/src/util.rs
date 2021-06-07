use lazy_static::lazy_static;
use regex::Regex;

pub fn crop(s: &str, n: usize) -> &str {
    if s.len() < n {
        ""
    } else {
        &s[n..]
    }
}

pub fn looks_like_cid(part: &str) -> bool {
    lazy_static! {
        static ref NAIVE_CID_PATTERN: Regex = Regex::new("^[a-z2-7]{32,128}$").unwrap();
    }
    NAIVE_CID_PATTERN.is_match(part)
}
