
map<string, string> table;
vector<string> table_list;
void add_to_table(string id, string type) {
//默认值都存储为0
    table.insert(pair<string, string>(id,type));
    table_list.push_back(id);
}
int lookup(string id) {
	return table.count(id);
}