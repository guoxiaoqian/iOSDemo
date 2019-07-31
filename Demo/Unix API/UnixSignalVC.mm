//
//  CrashSignalVC.m
//  Demo
//
//  Created by 郭晓倩 on 2018/12/29.
//  Copyright © 2018年 郭晓倩. All rights reserved.
//

#import "UnixSignalVC.h"
#import <signal.h>

static struct {int no; const char* v;} rqd_signal_names[] = {
    { SIGHUP,   "SIGHUP" },
    { SIGINT,   "SIGINT" },
    { SIGQUIT,  "SIGQUIT" },
    { SIGILL,   "SIGILL" },
    { SIGTRAP,  "SIGTRAP" },
    { SIGABRT,  "SIGABRT" },
    //{ SIGPOLL,  "SIGPOLL" },
    { SIGIOT,   "SIGIOT" },
    { SIGEMT,   "SIGEMT" },
    { SIGFPE,   "SIGFPE" },
    { SIGKILL,  "SIGKILL" },
    { SIGBUS,   "SIGBUS" },
    { SIGSEGV,  "SIGSEGV" },
    { SIGSYS,   "SIGSYS" },
    { SIGPIPE,  "SIGPIPE" },
    { SIGALRM,  "SIGALRM" },
    { SIGTERM,  "SIGTERM" },
    { SIGURG,   "SIGURG" },
    { SIGSTOP,  "SIGSTOP" },
    { SIGTSTP,  "SIGTSTP" },
    { SIGCONT,  "SIGCONT" },
    { SIGCHLD,  "SIGCHLD" },
    { SIGTTIN,  "SIGTTIN" },
    { SIGTTOU,  "SIGTTOU" },
    { SIGIO,    "SIGIO" },
    { SIGXCPU,  "SIGXCPU" },
    { SIGXFSZ,  "SIGXFSZ" },
    { SIGVTALRM, "SIGVTALRM" },
    { SIGPROF,  "SIGPROF" },
    { SIGWINCH, "SIGWINCH" },
    { SIGINFO,  "SIGINFO" },
    { SIGUSR1,  "SIGUSR1" },
    { SIGUSR2,  "SIGUSR2" },
    { 0, NULL }
};

static struct {int no; int code; const char * v;} rqd_signal_codes[] =
{
    //SIGILL
    { SIGILL,   ILL_NOOP,       "ILL_NOOP"    },
    { SIGILL,   ILL_ILLOPC,     "ILL_ILLOPC"  },
    { SIGILL,   ILL_ILLTRP,     "ILL_ILLTRP"  },
    { SIGILL,   ILL_PRVOPC,     "ILL_PRVOPC"  },
    { SIGILL,   ILL_ILLOPN,     "ILL_ILLOPN"  },
    { SIGILL,   ILL_ILLADR,     "ILL_ILLADR"  },
    { SIGILL,   ILL_PRVREG,     "ILL_PRVREG"  },
    { SIGILL,   ILL_COPROC,     "ILL_COPROC"  },
    { SIGILL,   ILL_BADSTK,     "ILL_BADSTK"  },
    
    //SIGFPE
    { SIGFPE,   FPE_NOOP,       "FPE_NOOP"    },
    { SIGFPE,   FPE_FLTDIV,     "FPE_FLTDIV"  },
    { SIGFPE,   FPE_FLTOVF,     "FPE_FLTOVF"  },
    { SIGFPE,   FPE_FLTUND,     "FPE_FLTUND"  },
    { SIGFPE,   FPE_FLTRES,     "FPE_FLTRES"  },
    { SIGFPE,   FPE_FLTINV,     "FPE_FLTINV"  },
    { SIGFPE,   FPE_FLTSUB,     "FPE_FLTSUB"  },
    { SIGFPE,   FPE_INTDIV,     "FPE_INTDIV"  },
    { SIGFPE,   FPE_INTOVF,     "FPE_INTOVF"  },
    
    //SIGSEGV
    { SIGSEGV,  SEGV_NOOP,      "SEGV_NOOP"   },
    { SIGSEGV,  SEGV_MAPERR,    "SEGV_MAPERR" },
    { SIGSEGV,  SEGV_ACCERR,    "SEGV_ACCERR" },
    
    //SIGBUS
    { SIGBUS,   BUS_NOOP,       "BUS_NOOP"    },
    { SIGBUS,   BUS_ADRALN,     "BUS_ADRALN"  },
    { SIGBUS,   BUS_ADRERR,     "BUS_ADRERR"  },
    { SIGBUS,   BUS_OBJERR,     "BUS_OBJERR"  },
    
    //SIGTRAP
    { SIGTRAP,  TRAP_BRKPT,     "TRAP_BRKPT"  },
    { SIGTRAP,  TRAP_TRACE,     "TRAP_TRACE"  },
    { 0, 0, NULL }
};

void rqd_map_sig_name(siginfo_t * si, char * buf/*>30bytes*/, const char * &signame, const char *&sigcode)
{
    signame = buf;
    sigcode = buf+15;
    sprintf((char*)signame, "%d", si->si_signo);
    sprintf((char*)sigcode, "%d", si->si_code);
    for (int i=0; ; ++i)
    {
        if (rqd_signal_names[i].v == NULL) break;
        if (rqd_signal_names[i].no == si->si_signo)
        {
            signame = rqd_signal_names[i].v;
            break;
        }
    }
    for (int i=0; ; ++i)
    {
        if (!rqd_signal_codes[i].v) break;
        if (rqd_signal_codes[i].no == si->si_signo && rqd_signal_codes[i].code == si->si_code)
        {
            sigcode = rqd_signal_codes[i].v;
            break;
        }
    }
}


static void signal_handler(int signal, siginfo_t *info, void *uap) {
    const char *signame, *sigcode;
    char       temp[30];
    rqd_map_sig_name(info, temp, signame, sigcode);
    NSString *errType = [NSString stringWithFormat:@"%s", signame];
    NSString *errName = [NSString stringWithFormat:@"%s", sigcode];
    
    NSLog(@"receive signal type=%@ code=%@",errType,errName);
}




@interface UnixSignalVC ()

@end

@implementation UnixSignalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self install];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //连接XCode调试时，会先被XCode捕获
        raise(SIGABRT);
    });
}

- (BOOL)install {
    int fatalsigs[] = {SIGABRT, SIGBUS, SIGFPE, SIGILL, SIGSEGV, SIGTRAP};
    struct sigaction sa = {0};
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO|SA_ONSTACK;
    sa.sa_sigaction = &signal_handler;
    
    int nok = 0;
    for (int i=0; i<sizeof(fatalsigs)/sizeof(int); ++i){
        nok += 0 == sigaction(fatalsigs[i], &sa, NULL);
    }
    return nok;
}

@end
