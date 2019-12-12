
class code_item
{
    public:
        string op;
        Node* res;
        Node* arg1;
        Node* arg2;
        int goto_pos = -1;
};
vector<code_item*> code_list;
int temp_count = 0;

void print_code()
{
    for(int i = 0; i < code_list.size(); i++) {
        cout<<i<<" "<<"op: "<<code_list[i]->op<<" ";
        if(code_list[i]->res){
            cout<<"res: "<<code_list[i]->res->key<<" ";
        }
		if(code_list[i]->arg1){
            cout<<"arg1: "<<code_list[i]->arg1->key<<" ";
        }
        if(code_list[i]->arg2){
            cout<<"arg2: "<<code_list[i]->arg2->key<<" ";
        }
        if(code_list[i]->goto_pos != -1){
            cout<<"goto_pos: "<<code_list[i]->goto_pos<<" ";
        }
		cout<<endl;
    }
}
//新产生一个临时变量名
string newtemp() {
    char buffer[10];
    return "temp"+string(itoa(temp_count++,buffer,10));
}
//声明语句中的赋值表达式
void gen_code_AssignExprInt(Node* p) {
    code_item* item = new code_item();
    item->op = "=";
    item->res = p->children[0];
    item->arg1 = p->children[1];
    code_list.push_back(item);
}
//二元运算表达式
void gen_code_Expr_two(Node* p, string op) {
    code_item* item = new code_item();
    item->op = op;
    item->res = p;
    p->key = newtemp();
    p->istemp = true;
    item->arg1 = p->children[0];
    item->arg2 = p->children[1];
    code_list.push_back(item);
}
void gen_code(Node* p) {
    vector<Node*> tree = p->children;
    // cout<<p->key<<" "<<p->isexpr<<endl;
    string key = p->key;
    if(key == "VarInt") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "AssignExprInt") {
        gen_code_AssignExprInt(p);
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "RepeatKFor") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "Conditionif") {
        gen_code(tree[0]);
        code_item* item1 = new code_item();//跳转到条件为真的执行语句
        item1->op = "==";
        item1->arg1 = p->children[0];
        item1->arg2 = new Node("zero", 0);
        item1->goto_pos = code_list.size() + 2;
        code_list.push_back(item1);
        code_item* item2 = new code_item();//跳转到if语句末尾
        code_list.push_back(item2);
        gen_code(tree[1]);
        item2->goto_pos = code_list.size();
    }
    else if(key == "Conditionelse") {
        gen_code(tree[0]);
        code_item* true_place = new code_item();
        true_place->op = "==";
        true_place->arg1 = p->children[0];
        true_place->arg2 = new Node("zero", 0);
        true_place->goto_pos = code_list.size() + 2;
        code_list.push_back(true_place);
        code_item* false_place = new code_item();
        code_list.push_back(false_place);
        
        gen_code(tree[1]);
        code_item* next = new code_item();
        code_list.push_back(next);
        false_place->goto_pos = code_list.size();

        gen_code(tree[2]);
        next->goto_pos = code_list.size();
    }
    else if(key == "Conditionelseif") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "ForHeader") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "RepeatKWhile") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
    else if(key == "Expr+") { 
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "+");
    }
    else if(key == "Expr-") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "-");
    }
    else if(key == "Expr*") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "*");
    }
    else if(key == "Expr/") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "/");
    }
    else if(key == "Expr%") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "%");
    }
    else if(key == "Expr&&") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "&&");
    }
    else if(key == "Expr||") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "||");
    }
    else {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
}


