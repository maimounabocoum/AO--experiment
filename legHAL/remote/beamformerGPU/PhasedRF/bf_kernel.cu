__constant__ float m_speedOfSound;
__constant__ float m_invSpeedOfSound;
__constant__ float m_piezoPitch;
__constant__ float m_sampFreq;
__constant__ float m_rOrigin;
__constant__ float m_fNumber;
__constant__ float m_peakDelay;
__constant__ float m_xSource[NB_MAX_SOURCES];
__constant__ float m_zSource[NB_MAX_SOURCES];
__constant__ float m_zApex;
__constant__ float m_linePitch;
__constant__ float m_pixelPitch;
__constant__ float m_lambda;
__constant__ float m_thetaOrigin;
__constant__ int   m_nbPiezos;
__constant__ int   m_nbSources;
__constant__ int   m_channelOffset;
__constant__ int   m_firstSample;
__constant__ int   m_nbSamples;
__constant__ int   m_nbLinesPerRecon;
__constant__ int   m_nbPixelsPerLine;
__constant__ int   m_nbRecon;
__constant__ int   m_normMode;
__constant__ int   m_synthAcq;
__constant__ int   m_frame_per_frame;
__constant__ int   m_idxTransmitToBeamform;
__constant__ int   m_idxFrame;
__constant__ int   m_nbImages;
__constant__ int   m_usegpu;

__global__ void Mafalda_rf_beamform_kernel_rectgrid200_source_frames(const short* pInRF,const int bufferSize,float* pOutImageRF, int frame)
{    
// output pixel coords
    int ix = IMUL(blockDim.x, blockIdx.x) + threadIdx.x;  // recon
    int iy = IMUL(blockDim.y, blockIdx.y) + threadIdx.y;  // sample (depth)

    if(ix< m_nbRecon && iy < m_nbPixelsPerLine)
     float thetaRecon = ix*m_nbLinesPerRecon*m_linePitch + m_thetaOrigin;
   
		float RfromApex = (float)iy * m_pixelPitch + m_rOrigin;
        float aperture = RfromApex/m_fNumber;
		int halfAperture = (int) roundf(0.5f * aperture /m_piezoPitch);
        int firstChannel0 = m_nbPiezos/2 - halfAperture; 
        int lastChannel0 = m_nbPiezos/2 + halfAperture;
        
		const float w0 = -1.0f/6.0f;
		const float w1 = 0.5f;
		const float w2 = -0.5f;
		const float w3 = 1.0f/6.0f;
		const float eps = 0.000001f;
		const float normal_fudge = 1.0f;

		int firstChannel = 0;
		int lastChannel  = min(NB_ACQ_CHANNELS,m_nbPiezos);		

	    float normCoef = eps;
		float RF;
		int offset;
        
		for (int channel = firstChannel; channel < lastChannel; channel++)
		{
		    offset = (channel % NB_ACQ_CHANNELS) * m_channelOffset + m_synthAcq * (channel / NB_ACQ_CHANNELS) * m_nbSamples ;
            offset+= (1+m_synthAcq)*m_idxFrame*m_nbSamples ;
            
		    float apodCoef = 1;//%apod(channel - firstChannel0, lastChannel0 - firstChannel0+1);
		    float xPiezo = (float)(channel + 0.5f - m_nbPiezos/2) * m_piezoPitch;
		    float zPiezo = m_zApex;

		        const short* channelStartPtr = pInRF + offset;// + (1+m_synthAcq)*m_nbSamples;
		        		        
		        for (int iPixel = 0; iPixel < m_nbLinesPerRecon; iPixel++)
		        {
                    int columnOffset = (ix*m_nbLinesPerRecon+iPixel) * m_nbPixelsPerLine;
                    float thetaLine = thetaRecon + iPixel * m_linePitch;
                    
                    float X = RfromApex*sinf(thetaLine);
                    float Z = RfromApex*cosf(thetaLine);
                    float forwardDelay = sqrtf((X-m_xSource[frame])*(X-m_xSource[frame]) + (Z-m_zSource[frame])*(Z-m_zSource[frame]))*m_invSpeedOfSound;
                    float returnDelay  = sqrtf((Z-zPiezo) * (Z-zPiezo) + (X - xPiezo) * (X - xPiezo)) * m_invSpeedOfSound;
		            float timeDelay = forwardDelay + returnDelay+(float)(2e-6); //+ m_timeOrigin[iSource];
                   
		            int delay = (int) floorf(timeDelay * m_sampFreq) - m_firstSample;
                    
					float deltaDelay = timeDelay * m_sampFreq - m_firstSample - float(delay); 
				   

				    if(delay < 0) 
                    {
                        delay = 1 ;
						deltaDelay = 0.0;
                    }
                    
                    if( 2*delay-2+1 + offset >= bufferSize ) 
                    {
                        delay = 1 ;
						deltaDelay = 0.0;
                    }

		          RF = (1-deltaDelay)*channelStartPtr[delay] + (deltaDelay)*channelStartPtr[delay+1];

                  pOutImageRF[columnOffset + iy] += RF*apodCoef;
		        }

		    normCoef += apodCoef * apodCoef;
		}

		if (m_normMode < 100)
		{
		    for (int iPixel = 0; iPixel < m_nbLinesPerRecon; iPixel++)
		    {
                int columnOffset = (ix*m_nbLinesPerRecon+iPixel) * m_nbPixelsPerLine;
                pOutImageRF[columnOffset + iy] /= normCoef;
		        pOutImageRF[columnOffset + iy] *= normal_fudge;
		    }
		}
		else
		{
		    for (int iPixel = 0; iPixel < m_nbLinesPerRecon; iPixel++)
		    {
                int columnOffset = (ix*m_nbLinesPerRecon+iPixel) * m_nbPixelsPerLine;
                pOutImageRF[columnOffset + iy] /= sqrtf(normCoef);
		    }
		}
    }
}
