use lazy_regex::*;

static NAIVE_CID_PATTERN: Lazy<Regex> = lazy_regex!("^[a-z2-7]{32,128}$");

pub fn crop(s: &str, n: usize) -> &str {
    if s.len() < n {
        ""
    } else {
        &s[n..]
    }
}

pub fn looks_like_cid(part: &str) -> bool {
    NAIVE_CID_PATTERN.is_match(part)
}