
class table_node {
    public:
        string type;
        int* array = NULL;
        int length = 0;
        int real_length = 0;
};
map<string, table_node*> table;
vector<string> table_list;
void add_to_table(string id, string type) {
    table_node* node = new table_node();
    node->type = type;
    table.insert(pair<string, table_node*>(id,node));
    table_list.push_back(id);
}
int lookup(string id) {
	return table.count(id);
}