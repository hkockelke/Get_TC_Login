using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

enum ExpImp_TC_Dir
{
    EXP_TO_TC = 1,
    IMP_FROM_TC = 0
}

namespace Get_TC_Login
{
    static class Program
    {
        /// <summary>
        /// Start the Login exe
        /// Arguments
        /// 0 : Import from Teamcenter (additional Dir for zip file)
        /// 1 : Export to Teamcenter (additional argument Dir+[SAPMatNo][Rev].zip)
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            string[] arguments = Environment.GetCommandLineArgs();
            int i_ECAD_dir = (int)ExpImp_TC_Dir.IMP_FROM_TC;
            string SAPMatNo_Rev = string.Empty;
            string ELCAD_type = string.Empty;
            if (arguments.Length > 1)
            {
                //MessageBox.Show(string.Join(", ", arguments), "GetCommandLineArgs");
                String ECAD_Dir = arguments[1];

                if (!int.TryParse(ECAD_Dir, out i_ECAD_dir))
                {
                    i_ECAD_dir = (int)ExpImp_TC_Dir.IMP_FROM_TC; // the default
                }
                if (i_ECAD_dir == 0 && arguments.Length > 2)
                {
                    SAPMatNo_Rev = arguments[2];
                }
                if (i_ECAD_dir == 1 && arguments.Length > 2)
                {
                    SAPMatNo_Rev = arguments[2];
                    if (arguments.Length > 3) { 
                       ELCAD_type = arguments[3];
                    }
                }

            }

            Application.Run(new Form1(i_ECAD_dir, SAPMatNo_Rev, ELCAD_type));
        }
    }
}
