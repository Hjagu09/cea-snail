void EXPOSE(print)(std::string x)
{
	#if defined(__EMSCRIPTEN__)
	output(&x[0], x.length());
	#else
	std::cout << x << std::endl;
	#endif
}

void EXPOSE(for)(int low, int high, std::function<void(int)> action)
{
	for (int i = low; i < high; i++)
	{
		action(i);
	}
}
