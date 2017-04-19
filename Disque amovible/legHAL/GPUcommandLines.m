%setenv('PATH', [getenv('PATH') ';C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin']);
system('nvcc -ptx bf_kernel.cu -use_fast_math -arch=sm_35')