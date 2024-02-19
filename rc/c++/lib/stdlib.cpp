void EXPOSE(print)(std::string x)
{
	#if defined(__EMSCRIPTEN__)
	output(&x[0], x.length());
	#else
	std::cout << x << std::endl;
	#endif
}
std::string EXPOSE(input)(std::string promt){
    #if defined(__EMSCRIPTEN__)
    set_promt(&promt[0], promt.length());
    input_setup();
    while (1)
    {
    	if (!check_input())
    	{
    		return std::string(input());
    	}
    	emscripten_sleep(100);
    }
    #else
    std::cout << promt;
    std::string x;
    std::cin >> x;
    std::cout << std::endl;
    return x;
    #endif
}

void EXPOSE(for)(int low, int high, std::function<void(int)> action)
{
	for (int i = low; i < high; i++)
	{
		action(i);
	}
}
void EXPOSE(for_ever)(std::function<bool()> action)
{
	while (true)
	{
		if (action())
		{
			break;
		}
	}
}
