// Sourabh Pardeshi - 801081931 - spardes1@uncc.edu
// CUDA Programming

#include <iostream>
#include <chrono>


__global__ void polynomial_expansion (float* poly, int degree, int n, float* array)
{
  //TODO: Write code to use the GPU here!
  //code should write the output back to array
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  
  if (idx < n)
  {
  	float output = 0.0;
  	float xponential = 1.0;
  	
  	for (int i = 0; i <= degree; i++)
  	{
      output += xponential * poly [i];
      xponential *= array [idx];
    }
    
    array [idx] = output;
  }

}


int main (int argc, char* argv[]) {
  //TODO: add usage
  
  if (argc < 3) {
     std::cerr<<"usage: "<<argv[0]<<" n degree"<<std::endl;
     return -1;
  }

  int n = atoi(argv[1]); //TODO: atoi is an unsafe function
  int degree = atoi(argv[2]);
  int nbiter = 1;

  float* array = new float[n];
  float* poly = new float[degree+1];
  for (int i=0; i<n; ++i)
    array[i] = 1.;

  for (int i=0; i<degree+1; ++i)
    poly[i] = 1.;

  
  std::chrono::time_point<std::chrono::system_clock> begin, end;
  begin = std::chrono::system_clock::now();
  
  float *arr_1, *poly_1;
  
  cudaMallocManaged (&arr_1, n * sizeof (float));
  cudaMallocManaged (&poly_1, (degree + 1) * sizeof (float));
  
  cudaMemcpy (arr_1, array, n * sizeof (float), cudaMemcpyHostToDevice);
  cudaMemcpy (poly_1, poly, n * sizeof (float), cudaMemcpyHostToDevice);

  cudaDeviceSynchronize();
  end = std::chrono::system_clock::now();
  
  for (int iter = 0; iter<nbiter; ++iter)
    polynomial_expansion <<< (n+255) / 256, 256 >>> (poly_1, degree, n, arr_1);
	
  cudaMemcpy(array, arr_1, n * sizeof(float), cudaMemcpyDeviceToHost);

  cudaFree(arr_1);
  cudaFree(poly_1);

  cudaDeviceSynchronize();
  end = std::chrono::system_clock::now();
  std::chrono::duration <double> totaltime = (end-begin)/nbiter;

  {
    bool correct = true;
    int ind;
    for (int i=0; i< n; ++i) {
      if (fabs(array[i]-(degree+1))>0.01) {
        correct = false;
	ind = i;
      }
    }
    if (!correct)
      std::cerr<<"Result is incorrect. In particular array["<<ind<<"] should be "<<degree+1<<" not "<< array[ind]<<std::endl;
  }
  

  std::cerr<<array[0]<<std::endl;
  std::cout<<n<<" "<<degree<<" "<<totaltime.count()<<std::endl;

  delete[] array;
  delete[] poly;

  return 0;
}
