using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace KuduDeployTest.Services
{
    public interface ISmsSender
    {
        Task SendSmsAsync(string number, string message);
    }
}
