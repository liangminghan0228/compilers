
string pointer_plus(Node* p) {
    string type = p->type + "*";
    return type;
}

string pointer_minus(Node* p) {
    string type = p->type.substr(0, p->type.length()-1);
    return type;
}
bool parse_error = false;