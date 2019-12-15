
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
    sprintf(buffer, "%d", temp_count++);
    return "temp" + string(buffer);
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

//一元运算表达式
void gen_code_Expr_one(Node* p, string op) {
    code_item* item = new code_item();
    item->op = op;
    item->res = p;
    p->key = newtemp();
    p->istemp = true;
    item->arg1 = p->children[0];
    code_list.push_back(item);
}
void gen_code(Node* p) {
    vector<Node*> tree = p->children;
    // cout<<p->key<<" "<<p->isexpr<<endl;
    string key = p->key;
    if(key == "AssignExprInt") { 
        gen_code(tree[1]);
        gen_code_AssignExprInt(p);
    }
    else if(key == "RepeatKFor") {
        gen_code(tree[0]->children[0]);
        int begin = code_list.size();
        
        gen_code(tree[0]->children[1]);
        code_item* true_place = new code_item();
        true_place->op = "!=";
        true_place->arg1 = tree[0]->children[1];
        true_place->arg2 = new Node("0", 0);
        true_place->goto_pos = code_list.size() + 2;
        code_list.push_back(true_place);

        code_item* false_place = new code_item();
        code_list.push_back(false_place);

        gen_code(tree[1]);
        gen_code(tree[0]->children[2]);

        code_item* goto_begin = new code_item();
        code_list.push_back(goto_begin);
        goto_begin->goto_pos = begin;
        false_place->goto_pos = code_list.size();
    }
    else if(key == "Conditionif") {
        gen_code(tree[0]);
        code_item* true_place = new code_item();
        true_place->op = "!=";
        true_place->arg1 = tree[0];
        true_place->arg2 = new Node("0", 0);
        true_place->goto_pos = code_list.size() + 2;
        code_list.push_back(true_place);

        code_item* false_place = new code_item();
        code_list.push_back(false_place);
        gen_code(tree[1]);
        false_place->goto_pos = code_list.size();
    }
    else if(key == "Conditionelse") {
        gen_code(tree[0]);
        code_item* true_place = new code_item();
        true_place->op = "!=";
        true_place->arg1 = tree[0];
        true_place->arg2 = new Node("0", 0);
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
    else if(key == "RepeatKWhile") {
        int begin = code_list.size();
        gen_code(tree[0]);
        code_item* true_place = new code_item();
        true_place->op = "!=";
        true_place->arg1 = tree[0];
        true_place->arg2 = new Node("0", 0);
        true_place->goto_pos = code_list.size() + 2;
        code_list.push_back(true_place);

        code_item* false_place = new code_item();
        code_list.push_back(false_place);

        gen_code(tree[1]);
        code_item* goto_begin = new code_item();
        code_list.push_back(goto_begin);
        goto_begin->goto_pos = begin;
        false_place->goto_pos = code_list.size();

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
    else if(key == "Expr^") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "^");
    }
    else if(key == "Expr>") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, ">");
    }
    else if(key == "Expr>=") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, ">=");
    }
    else if(key == "Expr<") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "<");
    }
    else if(key == "Expr<=") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "<=");
    }
    else if(key == "Expr!=") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "!=");
    }
    else if(key == "Expr==") {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
        gen_code_Expr_two(p, "==");
    }
     else if(key == "Expr=") {
     if(lookup(tree[0]->key))
     {
        gen_code(tree[1]);
        gen_code_AssignExprInt(p);
     }
     else{
         cout<<tree[0]->key<<"未声明的变量"<<endl;
     }
    }
    else if(key == "Expr!") {
        gen_code(tree[0]);
        gen_code_Expr_one(p, "!");
    }
    else if(key == "Expri++") {
        gen_code(tree[0]);
        gen_code_Expr_one(p, "++");
    }
    else if(key == "Expr++i") {
        gen_code(tree[0]);
        code_item* item = new code_item();
        item->op = "++";
        item->res = p;
        p->key = newtemp();
        p->istemp = true;
        item->arg2 = p->children[0];
        code_list.push_back(item);
    }
    else if(key == "Expri--") {
        gen_code(tree[0]);
        gen_code_Expr_one(p, "--");
    }
    else if(key == "Expr--i") {
        gen_code(tree[0]);
        code_item* item = new code_item();
        item->op = "--";
        item->res = p;
        p->key = newtemp();
        p->istemp = true;
        item->arg2 = p->children[0];
        code_list.push_back(item);
    }
    else {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
}

// void change_arg_name() {
//     for(int i=0; i<code_list.size(); i++) {
//         if(code_list[i]->arg1 && !(code_list[i]->arg1->key[0]>='0' && code_list[i]->arg1->key[0] <= '9')) {
//             code_list[i]->arg1->key = "[" + code_list[i]->arg1->key +"]";
//         }
//     }
// }


