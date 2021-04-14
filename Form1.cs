using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;

namespace Get_TC_Login
{
    public partial class Form1 : Form
    {
        static String TC_Login_file;
        static String TC_SAP_MN;
        static String ELCAD_ImportFromTC_CMD;
        static String ELCAD_ExportToTC_CMD;
        static String ELCAD_TC_Dir;
        static String ELCAD_Work_Dir;
        static String selected_Exp2TC_Proj;

        public Form1(int tc_dir, string SAPMatNo_Dir)
        {
            InitializeComponent();
            string SPLM_APPL_DIR = Environment.GetEnvironmentVariable("SPLM_APPL_DIR");
            string SPLM_TMP_DIR = Environment.GetEnvironmentVariable("SPLM_TMP_DIR");
            
            if (string.IsNullOrEmpty(SPLM_APPL_DIR))
            { 
                errorProvider1.SetError(comboBox_ExpImpTC, "SPLM_APPL_DIR not set");
            }
            if (string.IsNullOrEmpty(SPLM_TMP_DIR))
            {
                errorProvider1.SetError(comboBox_ExpImpTC, "SPLM_TMP_DIR not set");
            }

            this.textBox_Passw.UseSystemPasswordChar = true;
            comboBox_ExpImpTC.SelectedIndex = tc_dir; // 0:Import from TC; 1: Export to TC

            ELCAD_Work_Dir = Path.Combine(SPLM_TMP_DIR, "ELCAD");
            if (!Directory.Exists(ELCAD_Work_Dir))
            {
                errorProvider1.SetError(comboBox_ExpImpTC, "ELCAD Work-Dir not exists: " + ELCAD_Work_Dir);
                try
                {
                    Directory.CreateDirectory(ELCAD_Work_Dir);
                }
                catch (Exception ex1)
                {
                    string errMsg = "Create ELCAD Work-Dir Exception: " + ex1.Message;
                    MessageBox.Show(errMsg, "ELCAD", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }

            if (tc_dir == 1 && !(string.IsNullOrEmpty(SAPMatNo_Dir)))
            {
                selected_Exp2TC_Proj = SAPMatNo_Dir;
                textBox_SelProj.Text = Path.Combine(ELCAD_Work_Dir, SAPMatNo_Dir);
                /*
                string[] SAPMatNo_Dir_array = SAPMatNo_Dir.Split('_');
                if (SAPMatNo_Dir_array.Length == 2)
                {
                    textBox_SAP_MN.Text = SAPMatNo_Dir_array[0];
                    textBox_SAP_Rev.Text = SAPMatNo_Dir_array[1];
                }
                */
            }

            TC_Login_file = Path.Combine(ELCAD_Work_Dir, "TC_Login.cmd");
            TC_SAP_MN = Path.Combine(ELCAD_Work_Dir,"TC_SAP_MN.cmd");
            ELCAD_TC_Dir = SPLM_APPL_DIR + @"\nx120_plmshare\pmprodlocal\pm_tools\ELCAD_Data";
            ELCAD_ImportFromTC_CMD = Path.Combine(ELCAD_TC_Dir, "PM_ELCAD_Import_TC.cmd");
            ELCAD_ExportToTC_CMD = Path.Combine(ELCAD_TC_Dir, "import_ELCAD_Data.cmd");
        }

        private void button_OK_Click(object sender, EventArgs e)
        {
            //File.WriteAllText(TC_Login_file, textBox_user.Text + Environment.NewLine);
            //File.AppendAllText(TC_Login_file, textBox_Passw.Text + Environment.NewLine);
            //File.AppendAllText(TC_Login_file, textBox_group.Text + Environment.NewLine);
            int err_code = 0;
            string err_msg = string.Empty;

            File.WriteAllText(TC_Login_file, "set \"UPG=-u=");
            File.AppendAllText(TC_Login_file, textBox_user.Text);
            File.AppendAllText(TC_Login_file, " -p=");
            File.AppendAllText(TC_Login_file, textBox_Passw.Text);
            File.AppendAllText(TC_Login_file, " -g=");
            File.AppendAllText(TC_Login_file, textBox_group.Text);
            File.AppendAllText(TC_Login_file, "\"");

            // 0:Import from TC; 1: Export to TC)
            if (comboBox_ExpImpTC.SelectedIndex == 0)
            {   
                File.WriteAllText(TC_SAP_MN, "set SAP_MN=");
                File.AppendAllText(TC_SAP_MN, textBox_SAP_MN.Text + Environment.NewLine);
                File.AppendAllText(TC_SAP_MN, "SET SAP_Rev=");
                File.AppendAllText(TC_SAP_MN, textBox_SAP_Rev.Text + Environment.NewLine);
                File.AppendAllText(TC_SAP_MN, "SET checkout=");
                File.AppendAllText(TC_SAP_MN, checkout.Checked.ToString() + Environment.NewLine);

                if (File.Exists(ELCAD_ImportFromTC_CMD))
                {

                    ProcessStartInfo startInfo = new ProcessStartInfo(ELCAD_ImportFromTC_CMD);
                    startInfo.WorkingDirectory = ELCAD_Work_Dir;
                    startInfo.WindowStyle = ProcessWindowStyle.Normal;

                    String arg_1 = textBox_SAP_MN.Text + "_" + textBox_SAP_Rev.Text + " " + checkout.Checked.ToString();
                    startInfo.Arguments = arg_1;
                    Process myProcess = Process.Start(startInfo);

                    myProcess.WaitForExit();
                    err_code = myProcess.ExitCode;
                    err_msg = "Error: Import from TC: " + err_code.ToString();
                }
                else
                {
                    err_code = 20;
                    err_msg = "Error: CMD file does not exist " + ELCAD_ImportFromTC_CMD;
                }
            }
            else if (comboBox_ExpImpTC.SelectedIndex == 1)
            {
                if (File.Exists(ELCAD_ExportToTC_CMD))
                {
                    ProcessStartInfo startInfo = new ProcessStartInfo(ELCAD_ExportToTC_CMD);
                    startInfo.WorkingDirectory = ELCAD_Work_Dir;
                    startInfo.WindowStyle = ProcessWindowStyle.Normal;

                    String arg_1 = selected_Exp2TC_Proj;
                    startInfo.Arguments = arg_1;
                    Process myProcess = Process.Start(startInfo);

                    myProcess.WaitForExit();

                    err_code = myProcess.ExitCode;
                    err_msg = "Error: Export to TC: " + err_code.ToString();
                }
                else
                {
                    err_code = 20;
                    err_msg = "Error: CMD file does not exist " + ELCAD_ExportToTC_CMD;
                }
            }
            else
            {
                err_msg = "This function is n/a";
                err_code = 2;
            }
            
            if (err_code != 0)
            {
                //MessageBox.Show("Error: " + err_code, "Export Teamcenter to ELCAD");
                errorProvider1.SetError(comboBox_ExpImpTC, err_msg);
            }
            else {
                Close();
            }
        }

        private void button_cancel_Click(object sender, EventArgs e)
        {
            File.Delete(TC_Login_file);
            File.Delete(TC_SAP_MN);
            Close();
        }

        private void textBox_Passw_TextChanged(object sender, EventArgs e)
        {
            if (!(string.IsNullOrEmpty(textBox_user.Text) || string.IsNullOrEmpty(textBox_Passw.Text)))
            {
                button_OK.Enabled = true;
            }
        }

        private void textBox_group_TextChanged(object sender, EventArgs e)
        {

        }

        private void label_group_Click(object sender, EventArgs e)
        {

        }

        private void label_password_Click(object sender, EventArgs e)
        {

        }

        private void textBox_user_TextChanged(object sender, EventArgs e)
        {
            if (! (string.IsNullOrEmpty(textBox_user.Text) || string.IsNullOrEmpty(textBox_Passw.Text)))
            {
                button_OK.Enabled = true;
            }
        }

        private void label_user_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void folderBrowserProject_HelpRequest(object sender, EventArgs e)
        {

        }

        private void button_selProj_Click(object sender, EventArgs e)
        {
            DialogResult result = folderBrowserProject.ShowDialog();
            if (result == DialogResult.OK)
            {
                textBox_SelProj.Text = folderBrowserProject.SelectedPath;
                selected_Exp2TC_Proj = Path.GetFileName(textBox_SelProj.Text);
                //MessageBox.Show(selected_Exp2TC_Proj, "Debug");
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            // 0:Import from TC; 1: Export to TC
            if (comboBox_ExpImpTC.SelectedIndex == 1)
            {
                groupBox_Imp.Enabled = false;
                groupBox_Exp.Enabled = true;
            }
            else if (comboBox_ExpImpTC.SelectedIndex == 0)
            {
                groupBox_Imp.Enabled = true;
                groupBox_Exp.Enabled = false;
            }
            
        }
    }
}
