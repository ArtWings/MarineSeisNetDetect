#include <afx.h>

#include "FilterInclude.h"
#include "DspFilters/Dsp.h"

CString CMyApp::CurrentDir;
int CMyApp::SampleRate;
int CMyApp::Order;
int CMyApp::CenterFreq;
int CMyApp::BandWidth;

BEGIN_MESSAGE_MAP(CMainWnd, CFrameWnd)	
	ON_WM_PAINT()
END_MESSAGE_MAP()

CMainWnd::CMainWnd()
{
	
	Create(NULL,_T("AutomaticFilter"),WS_OVERLAPPEDWINDOW,CRect(0,0,160,240),NULL,NULL);
	//LoopingProc();
}

void CMainWnd::OnPaint()
{
	CPaintDC dc(this);
}

void CMyApp::LoopingProc()
{
	//CMyApp::CurrentDir = _T("C:\\FilesForProcess\\");
	//CMyApp::SampleRate = 64;
	//CMyApp::Order = 5;
	//CMyApp::CenterFreq = 13;
	//CMyApp::BandWidth = 14;
	BOOL Dir = SetCurrentDirectory(CMyApp::CurrentDir);
	CFileFind finderLocal;
	BOOL bWorkingLocal = finderLocal.FindFile(_T("*.*"));
	while (bWorkingLocal)
	{
		bWorkingLocal = finderLocal.FindNextFile();
		CString strLocalFile  = finderLocal.GetFileName();
		unsigned long int currentLocalLength = finderLocal.GetLength();
		unsigned long int CommonSampleCount = currentLocalLength/2;
		unsigned long int NumberOfChannels = 6;
		unsigned long int ChannelSampleCount = CommonSampleCount/NumberOfChannels;

		unsigned int i,j,k;
		
		short **a;
		a = new short*[10];
		float **b;
		b = new float*[10];

		short* a_stream;
		short* b_stream;
			
		a_stream = new short[CommonSampleCount];
		b_stream = new short[CommonSampleCount];

		for (i=0; i<10;i++)
		{
			a[i] = new short[ChannelSampleCount];
			b[i] = new float[ChannelSampleCount];
		}

		CFile Fin, Fout;
		
		if (strLocalFile!=_T(".") && strLocalFile!=_T(".."))
		{
		if (Fin.Open(strLocalFile, CFile::modeRead|CFile::shareDenyNone)!= NULL)
		{
			Fin.Read(a_stream, CommonSampleCount*2);
			Fin.Close();
		}
		else
		{
			AfxMessageBox(_T("Reading error"));
		}
		}

		for (i=0; i<NumberOfChannels;i++)
		{
			k = 0;
			for (j=i;j<CommonSampleCount;j=j+NumberOfChannels)
			{
				a[i][k] = a_stream[j];
				b[i][k] = (float)a[i][k];
				k = k+1;
			}
		}

		Dsp::Filter* f = new Dsp::FilterDesign
			<Dsp::Butterworth::Design::BandPass <50>,10>;
			Dsp::Params params;
			params[0] = CMyApp::SampleRate; // sample rate
			params[1] = CMyApp::Order; // order
			params[2] = CMyApp::CenterFreq; // central frequency
			params[3] = CMyApp::BandWidth; // band width
			f->setParams (params);
			f->process (ChannelSampleCount, b);
			delete f;


		for (i=0; i<NumberOfChannels;i++)
		{
			k = 0;
			for (j=i;j<CommonSampleCount;j=j+NumberOfChannels)
			{
				if (i!=NumberOfChannels-1)
					b_stream[j] = (short)b[i][k];
				else
					b_stream[j] = a[i][k];

				k = k+1;
			}
		}

		if (strLocalFile!=_T(".") && strLocalFile!=_T(".."))
		{
		if (Fin.Open(strLocalFile, CFile::modeCreate|CFile::modeWrite)!= NULL)
		{
			Fin.Write(b_stream, CommonSampleCount*2);
			Fin.Close();
		}
		else
		{
			AfxMessageBox(_T("Writing error"));
		}
		}

		delete [] a_stream;
		delete [] b_stream;
		for (i=0; i<10; i++) delete [] a[i];
		delete [] a;
		for (i=0; i<10; i++) delete [] b[i];
		delete [] b;




	}

	//AfxMessageBox(_T("Filtering complete"));
	::PostMessage(::FindWindow(NULL ,_T("AutomaticFilter")), WM_CLOSE, 0, 0);
}

BOOL CMainWnd::PreCreateWindow(CREATESTRUCT& cs)
{
	cs.style &= ~WS_MAXIMIZEBOX;
	cs.style &= ~WS_THICKFRAME;
	  
	//cs.cx = 1250;
	//cs.cy = 700;
	return CFrameWnd::PreCreateWindow(cs);
}

CMainWnd::~CMainWnd()
{
	
}

CMyApp::CMyApp() 
{}

void CMyApp::checkCmdLine()
{
	int i;
	
	LPWSTR sCmdLineW = GetCommandLineW();
	
	int nArgNumber = 0;
	
	LPWSTR* sArgs = CommandLineToArgvW(sCmdLineW, &nArgNumber);
	if( NULL == sArgs )
	{
         AfxMessageBox(_T("Command Line Error"));                // какое-то сообщение об ошибке
		return ;
	}
	for(i = 0; i < nArgNumber; i++) 
	{
		//AfxMessageBox(sArgs[i]);
		if (i==1)
			CMyApp::CurrentDir = sArgs[i];
		if (i==2)
			CMyApp::SampleRate = _wtoi(sArgs[i]);
		if (i==3)
			CMyApp::Order = _wtoi(sArgs[i]);
		if (i==4)
			CMyApp::CenterFreq = _wtoi(sArgs[i]);
		if (i==5)
			CMyApp::BandWidth = _wtoi(sArgs[i]);
		
	}
	
	

	
}

BOOL CMyApp::InitInstance()
{
	
	m_pMainWnd=new CMainWnd();	
	ASSERT(m_pMainWnd);	
	m_pMainWnd->ShowWindow(SW_SHOW);
	m_pMainWnd->UpdateWindow();	
	checkCmdLine();
	LoopingProc();
	return TRUE;		
};

CMyApp theApp;