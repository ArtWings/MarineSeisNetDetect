#include "afxwin.h" 


class CMyApp : public CWinApp
{
public:
	CMyApp();			
	virtual BOOL InitInstance();
	void checkCmdLine();
	static CString CurrentDir;
	static int SampleRate;
	static int Order;
	static int CenterFreq;
	static int BandWidth;
	void LoopingProc();

};


class CMainWnd : public CFrameWnd
{
public:
	CMainWnd();
	afx_msg void OnPaint();
	//void LoopingProc();
	~CMainWnd();
private:
			
	DECLARE_MESSAGE_MAP();

protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

};

