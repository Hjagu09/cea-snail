std::string EXPOSE(int_to_str)(int x) { return std::to_string(x); }
std::string EXPOSE(float_to_str)(float x) { return std::to_string(x); }
float EXPOSE(int_to_float)(int x) { return (float)(x); }
