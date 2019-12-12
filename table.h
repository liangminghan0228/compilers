
map<string, Node*> table;
// void add_to_table(string id, string type) {
// //默认值都存储为0
// 	item it;
// 	it.type = type;
//     table.insert(pair<string, item>(id, it));
// }
Node* lookup(string id) {
	if(table[id])
	{
		return table[id];
	}
	else
	{
		return NULL;
	}
	
}