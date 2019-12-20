
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
//声明语句中的int赋值表达式
void gen_code_AssignExprInt(Node* p) {
    code_item* item = new code_item();
    item->op = "=";
    item->res = p->children[0];
    item->arg1 = p->children[1];
    code_list.push_back(item);
}

//声明语句中的array赋值表达式,将信息添加到符号表
void gen_code_AssignExprArray(Node* p) {
    table_node* node = table[p->children[0]->children[0]->key];
    node->length = p->children[0]->children[1]->val;
    int real_length = p->children[1]->children.size();
    node->real_length = real_length;
    node->array = new int[real_length];
    for(int i=0;i<real_length;i++) {
        node->array[i] = p->children[1]->children[i]->val;
    }
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

//判断一个结点是否为数字常量
bool is_const_num(Node* p) {
    if((p->key[0]>='0'&&p->key[0]<='9')||p->key[0]=='-') {
        return true;
    }
    return false;
}
//将一个数字转化为字符串
string num_to_string(int n) {
    char buffer[10];
    sprintf(buffer, "%d", n);
    return string(buffer);
}
void gen_code(Node* p) {
    vector<Node*> tree = p->children;
    // cout<<p->key<<" "<<p->isexpr<<endl;
    string key = p->key;
    if(key == "AssignExprInt") { 
        gen_code(tree[1]);
        gen_code_AssignExprInt(p);
    }
    else if(key == "AssignExprArray")
    {
         gen_code_AssignExprArray(p);
    }
    
    else if(key == "Array") {
        //先计算tree[1]的值
        if(is_const_num(tree[1])) {
            table[tree[0]->key]->length = (table[tree[0]->key]->length == 0)?tree[1]->val:table[tree[0]->key]->length;
        }
        gen_code(tree[1]);
        p->key = newtemp();
        code_item* item = new code_item();
        item->op = "[]";
        item->res = p;
        item->arg1 = tree[0];
        item->arg2 = tree[1];
        p->istemp = true;
        code_list.push_back(item);
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
        //如果是数字就直接计算产生的值
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val + tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val + tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "+");
            }
        }
    }
    else if(key == "Expr-") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val - tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val - tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "-");
            }
        }
    }
    else if(key == "Expr*") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val * tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val * tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "*");
            }
        }
    }
    else if(key == "Expr/") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = int(tree[0]->val / tree[1]->val);
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = int(tree[0]->val / tree[1]->val);
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "/");
            }
        }
    }
    else if(key == "Expr%") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val % tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val % tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "%");
            }
        }
    }
    else if(key == "Expr&&") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val && tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val && tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "&&");
            }
        }
    }
    else if(key == "Expr||") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = tree[0]->val || tree[1]->val;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = tree[0]->val || tree[1]->val;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "||");
            }
        }
    }
    else if(key == "Expr^") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (int)pow(tree[0]->val, tree[1]->val);
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (int)pow(tree[0]->val, tree[1]->val);
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "^");
            }
        }
    }
    else if(key == "Expr>") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val > tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val > tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, ">");
            }
        }
    }
    else if(key == "Expr>=") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val >= tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val >= tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, ">=");
            }
        }
    }
    else if(key == "Expr<") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val < tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val < tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "<");
            }
        }
    }
    else if(key == "Expr<=") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val <= tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val <= tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "<=");
            }
        }
    }
    else if(key == "Expr!=") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val != tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val != tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "!=");
            }
        }
    }
    else if(key == "Expr==") {
        if(is_const_num(tree[0])&&is_const_num(tree[1])) {
            p->val = (tree[0]->val == tree[1]->val)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code(tree[1]);
            if(is_const_num(tree[0])&&is_const_num(tree[1])) {
                p->val = (tree[0]->val == tree[1]->val)?1:0;
                p->key = num_to_string(p->val);
            }
            else {
                gen_code_Expr_two(p, "==");
            }
        }
    }
     else if(key == "Expr=") {
     if(tree[0]->key == "Array") {
         gen_code(tree[0]);
     }
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
        if(is_const_num(tree[0])) {
            p->val = (tree[0]->val == 0)?1:0;
            p->key = num_to_string(p->val);
        }
        else {
            gen_code(tree[0]);
            gen_code_Expr_one(p, "!");
        }
    }
    else if(key == "Expr~") {
        gen_code(tree[0]);
        gen_code_Expr_one(p, "~");
    }
    else if(key == "Expr&") {
        gen_code(tree[0]);
        gen_code_Expr_one(p, "&");
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
    else if(key == "Writek") {
        gen_code(tree[0]);
        code_item* item = new code_item();
        item->op = "print";
        item->arg1 = tree[0];
        code_list.push_back(item);
    }
    else if(key == "Readk") {
        gen_code(tree[0]);
        code_item* item = new code_item();
        item->op = "scanf";
        item->arg1 = tree[0];
        code_list.push_back(item);
    }
    else {
        for(int i=0; i<tree.size(); i++) {
            gen_code(tree[i]);
        }
    }
}


