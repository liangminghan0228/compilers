
map<string, string> table;
void add_to_table(string id, string type) {
//默认值都存储为0
    table.insert(pair<string, string>(id,type));
}
int lookup(string id) {
	return table.count(id);
}