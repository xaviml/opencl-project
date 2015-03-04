__private int pos (int* size, int* y, int* x){
	return *size * *y + *x;
}
// Matrix multiplication kernel
__kernel void MatMulKernel(
    __global float *A,
    __global float *B,
    __global float *C,
    __local float *blockA,
    __local float *blockB
    )
{
	int idXgroup = get_group_id(0);
	int idYgroup = get_group_id(1);
	
	int idX = get_global_id(0);
	int idY = get_global_id(1);
	
	int idXlocal = get_local_id(0);
	int idYlocal = get_local_id(1);
	
	int global_size = get_global_size(0);
	int local_size = get_local_size(0);

	/* Codi de multiplicacio de les matrius A * B.
	Cada Work Item s'encarrega del resultat d'un punt de la matriu C.*/
	
	int p = pos(&global_size,&idY,&idX);
	C[p] = 0;
	for (int step=0; step<global_size; ++step){
		C[p] += A[pos(&global_size,&idY,&step)] * B[pos(&global_size,&step,&idX)];
		
		
	}	
	
	for(int k = 0; k < get_num_groups(0);++k){
		//loading of blockA and blockB
		for(int i = 0; i < local_size; ++i){
		      for(int j = 0; j < local_size; ++j){
			    blockA[pos(&local_size,&j,&i)] = A[idYgroup * global_size * local_size + j * global_size + k * local_size + i];
			    blockB[pos(&local_size,&j,&i)] = B[k * global_size * local_size + j * global_size + idXgroup * local_size + i];
			    
		      }
		
		}
		for(int i = 0; i < local_size; ++i){
		      for(int j = 0; j < local_size; ++j){
			  //warning, check the following code
			   C[p] += blockA[pos(&local_size, &j, &i)] * blockB[pos(&local_size,&i,&j)];
		      }
		
		}
	
	}
}

