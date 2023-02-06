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
using System.IO.Compression;
using Microsoft.VisualBasic.FileIO;

namespace Get_TC_Login
{
    public partial class Form1 : Form
    {
        static String TC_Login_file;
        static String TC_SAP_MN;
        static String ELCAD_ImportFromTC_CMD;
        static String ELCAD_ExportToTC_CMD;
        static String ELCAD_ExportToTC_ZIP;
        static String ELCAD_TC_Dir;
        static String ELCAD_Work_Dir;
        static String selected_Exp2TC_Proj;
        static String selected_CSV_File;
        static String ELCAD_IMP_TC_DIR;
        static String ELCAD_EXP_TC_DIR;
        static String ELCAD_TC_ATTR_Template;
        static Boolean b_test_system = false;

        public Form1(int tc_dir, string SAPMatNo_Dir, string ELCAD_type)
        {
            InitializeComponent();

            string USERPROFILE_DIR = Environment.GetEnvironmentVariable("USERPROFILE");
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
            comboBox_ELCAD_Type.SelectedIndex = mapping_elcad_type_input(ELCAD_type);

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
            ELCAD_EXP_TC_DIR = Path.Combine(ELCAD_Work_Dir, "export");

            if (tc_dir == 1 && !(string.IsNullOrEmpty(SAPMatNo_Dir)))
            {
                // expected full path to ZIP file
                if (File.Exists(SAPMatNo_Dir))
                {
                    ELCAD_ExportToTC_ZIP = SAPMatNo_Dir;
                    selected_Exp2TC_Proj = Path.GetFileNameWithoutExtension(SAPMatNo_Dir);
                    textBox_SelProj.Text = Path.GetFullPath(SAPMatNo_Dir);
                    ELCAD_EXP_TC_DIR = Path.GetDirectoryName(SAPMatNo_Dir);
                }
                else
                {
                    ELCAD_ExportToTC_ZIP = string.Empty;
                    errorProvider1.SetError(comboBox_ExpImpTC, "Export ZIP file does not exist: " + SAPMatNo_Dir);
                }
                /*
                string[] SAPMatNo_Dir_array = SAPMatNo_Dir.Split('_');
                if (SAPMatNo_Dir_array.Length == 2)
                {
                    textBox_SAP_MN.Text = SAPMatNo_Dir_array[0];
                    textBox_SAP_Rev.Text = SAPMatNo_Dir_array[1];
                }
                */
            }
            else if (tc_dir == 0)
            {
                // import from TC
                if (string.IsNullOrEmpty(SAPMatNo_Dir))
                {
                    ELCAD_IMP_TC_DIR = Path.Combine(ELCAD_Work_Dir, "import");
                }
                else
                {
                    ELCAD_IMP_TC_DIR = SAPMatNo_Dir;
                }
                if (!Directory.Exists(ELCAD_IMP_TC_DIR))
                {
                    errorProvider1.SetError(comboBox_ExpImpTC, "ELCAD Import-Dir not exists: " + ELCAD_IMP_TC_DIR);
                    try
                    {
                        Directory.CreateDirectory(ELCAD_IMP_TC_DIR);
                    }
                    catch (Exception ex1)
                    {
                        string errMsg = "Create ELCAD Import-Dir Exception: " + ex1.Message;
                        MessageBox.Show(errMsg, "ELCAD", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            else if (tc_dir == 2)
            {
                progressBar_CSV.Maximum = 1;
                progressBar_CSV.Step = 1;
                progressBar_CSV.Value = 0;
            }

            TC_Login_file = Path.Combine(USERPROFILE_DIR, "TC_Login.cmd");
            textBox_user.Text = GetTCUser(TC_Login_file);
            textBox_group.Text = GetTCGroup(TC_Login_file);
            if (!string.IsNullOrEmpty(textBox_user.Text))
            {
                this.ActiveControl = this.textBox_Passw;
            }
            TC_SAP_MN = Path.Combine(ELCAD_Work_Dir, "TC_SAP_MN.cmd");
            ELCAD_TC_ATTR_Template = Path.Combine(ELCAD_EXP_TC_DIR, "attribute_template.txt");
            // Update to TC 13 and NX1965:
            ELCAD_TC_Dir = SPLM_APPL_DIR + @"\nx_plmshare\pmprod13local\pm_tools\ELCAD_Data";
            if (b_test_system)
            {
                label_TestSystem.Visible = true;
                ELCAD_TC_Dir = SPLM_APPL_DIR + @"\nx_plmshare_test\pmtest13local\pm_tools\ELCAD_Data";
            }
            ELCAD_ImportFromTC_CMD = Path.Combine(ELCAD_TC_Dir, "PM_ELCAD_Import_TC.cmd");
            ELCAD_ExportToTC_CMD = Path.Combine(ELCAD_TC_Dir, "PM_ELCAD_Export_TC.cmd");
        }

        private void button_OK_Click(object sender, EventArgs e)
        {
            //File.WriteAllText(TC_Login_file, textBox_user.Text + Environment.NewLine);
            //File.AppendAllText(TC_Login_file, textBox_Passw.Text + Environment.NewLine);
            //File.AppendAllText(TC_Login_file, textBox_group.Text + Environment.NewLine);

            string unzip = "false"; // argument as string to cmd (Import from TC)
            int err_code = 0;
            string err_msg = string.Empty;

            File.WriteAllText(TC_Login_file, "set \"UPG=-u=");
            File.AppendAllText(TC_Login_file, textBox_user.Text);
            File.AppendAllText(TC_Login_file, " -p=");
            File.AppendAllText(TC_Login_file, textBox_Passw.Text);
            File.AppendAllText(TC_Login_file, " -g=");
            File.AppendAllText(TC_Login_file, textBox_group.Text);
            File.AppendAllText(TC_Login_file, "\"");

            // 0: Import from TC; 1: Export to TC; 2: Import from TC List)
            if (comboBox_ExpImpTC.SelectedIndex == 0)
            {
                File.WriteAllText(TC_SAP_MN, "REM Putzmeister ELCAD-TC interface" + Environment.NewLine);
                /*
                File.AppendAllText(TC_SAP_MN, "SET SAP_MN=");
                File.AppendAllText(TC_SAP_MN, textBox_SAP_MN.Text + Environment.NewLine);
                File.AppendAllText(TC_SAP_MN, "SET SAP_Rev=");
                File.AppendAllText(TC_SAP_MN, textBox_SAP_Rev.Text + Environment.NewLine);
                File.AppendAllText(TC_SAP_MN, "SET checkout=");
                File.AppendAllText(TC_SAP_MN, checkout.Checked.ToString() + Environment.NewLine);
                */
                if (string.IsNullOrEmpty(ELCAD_IMP_TC_DIR))
                {
                    ELCAD_IMP_TC_DIR = Path.Combine(ELCAD_Work_Dir, "import");
                }
                File.AppendAllText(TC_SAP_MN, "SET \"ELCAD_IMP_TC_DIR=");
                File.AppendAllText(TC_SAP_MN, ELCAD_IMP_TC_DIR + "\"" + Environment.NewLine);

                if (File.Exists(ELCAD_ImportFromTC_CMD))
                {

                    ProcessStartInfo startInfo = new ProcessStartInfo(ELCAD_ImportFromTC_CMD);
                    startInfo.WorkingDirectory = ELCAD_Work_Dir;
                    startInfo.WindowStyle = ProcessWindowStyle.Minimized;
                    string revision = textBox_SAP_Rev.Text.ToUpper();
                    if (b_test_system)
                    {
                        startInfo.UseShellExecute = false;
                        startInfo.EnvironmentVariables.Add("PM_TC_TEST", "1");
                    }

                    String arg_1 = textBox_SAP_MN.Text + " " + revision + " " + checkout.Checked.ToString() + " " + unzip;
                    startInfo.Arguments = arg_1;
                    //startInfo.WindowStyle = ProcessWindowStyle.Hidden;
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
            // Export to Teamcenter
            else if (comboBox_ExpImpTC.SelectedIndex == 1)
            {
                if (File.Exists(ELCAD_ExportToTC_CMD))
                {
                    ProcessStartInfo startInfo = new ProcessStartInfo(ELCAD_ExportToTC_CMD);
                    startInfo.WorkingDirectory = ELCAD_Work_Dir;
                    startInfo.WindowStyle = ProcessWindowStyle.Minimized;

                    int project_strlen = selected_Exp2TC_Proj.Length;
                    // last char is the revision
                    string revision = selected_Exp2TC_Proj.Substring(project_strlen - 1);
                    revision = revision.ToUpper();
                    string projectNo = selected_Exp2TC_Proj.Substring(0, project_strlen - 1);

                    string ELCAD_ExportToTC_ZIP_dir = Path.GetDirectoryName(textBox_SelProj.Text);

                    //System.IO.Compression.ZipFile.ExtractToDirectory(ELCAD_ExportToTC_ZIP, ELCAD_ExportToTC_ZIP_dir);

                    using (ZipArchive archive = ZipFile.OpenRead(textBox_SelProj.Text))
                    {
                        foreach (ZipArchiveEntry entry in archive.Entries)
                        {
                            // entry.FullName = "629214B.pro\\000008"
                            if (entry.FullName.ToLower().Contains("teamcenter"))
                            {
                                // Gets the full path to ensure that relative segments are removed.
                                string destinationPath = Path.GetFullPath(Path.Combine(ELCAD_ExportToTC_ZIP_dir, entry.FullName));
                                string destinationRoot = Path.GetDirectoryName(destinationPath);
                                //destinationRoot = Path.GetFullPath(Path.Combine(ELCAD_ExportToTC_ZIP_dir, destinationRoot));
                                if (!Directory.Exists(destinationRoot))
                                {
                                    Directory.CreateDirectory(destinationRoot);
                                }

                                // Ordinal match is safest, case-sensitive volumes can be mounted within volumes that
                                // are case-insensitive.
                                if (destinationPath.StartsWith(ELCAD_ExportToTC_ZIP_dir, StringComparison.Ordinal))
                                    entry.ExtractToFile(destinationPath, true);
                            }
                        }
                    }

                    if (b_test_system)
                    {
                        startInfo.UseShellExecute = false;
                        startInfo.EnvironmentVariables.Add("PM_TC_TEST", "1");
                    }

                    int rc_code = WriteAttrFile(ELCAD_TC_ATTR_Template);
                    string elcad_type = mapping_elcad_selection(comboBox_ELCAD_Type.SelectedIndex);
                    
                    //String arg_1 = selected_Exp2TC_Proj;
                    String arg_1 = projectNo + " " + revision + " " + elcad_type;
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
            // Import from TC List
            else if (comboBox_ExpImpTC.SelectedIndex == 2)
            {
                File.WriteAllText(TC_SAP_MN, "REM Putzmeister ELCAD-TC interface" + Environment.NewLine);
                if (string.IsNullOrEmpty(ELCAD_IMP_TC_DIR))
                {
                    ELCAD_IMP_TC_DIR = Path.Combine(ELCAD_Work_Dir, "import");
                }
                File.AppendAllText(TC_SAP_MN, "SET \"ELCAD_IMP_TC_DIR=");
                File.AppendAllText(TC_SAP_MN, ELCAD_IMP_TC_DIR + "\"" + Environment.NewLine);

                //err_msg = "This function is not implemented";
                //err_code = 3;
                if (!File.Exists(ELCAD_ImportFromTC_CMD))
                {
                    err_msg = "CMD not found:" + ELCAD_ImportFromTC_CMD;
                    err_code = 20;
                }
                else
                {
                    if (!string.IsNullOrEmpty(selected_CSV_File) && File.Exists(selected_CSV_File))
                    {
                        err_msg = "Error: Import from TC ";
                        progressBar_CSV.Value = 0;
                        progressBar_CSV.Step = 1;
                        progressBar_CSV.Maximum = File.ReadLines(selected_CSV_File).Count();

                        using (TextFieldParser csvParser = new TextFieldParser(selected_CSV_File))
                        {
                            csvParser.CommentTokens = new string[] { "#" };
                            csvParser.SetDelimiters(new string[] { ";" });
                            csvParser.HasFieldsEnclosedInQuotes = true;

                            while (!csvParser.EndOfData)
                            {
                                string[] fields = csvParser.ReadFields();
                                string SAPMatNo = fields[0];
                                string revision = fields[1];
                                unzip = "true";
                                label_working.Visible = true;
                                label_working.Text = SAPMatNo + ";" + revision + " ...";
                                
                                ProcessStartInfo startInfo = new ProcessStartInfo(ELCAD_ImportFromTC_CMD);
                                startInfo.WorkingDirectory = ELCAD_Work_Dir;
                                startInfo.WindowStyle = ProcessWindowStyle.Minimized;
                                if (b_test_system)
                                {
                                    startInfo.UseShellExecute = false;
                                    startInfo.EnvironmentVariables.Add("PM_TC_TEST", "1");
                                }
                                String arg_1 = SAPMatNo + " " + revision + " " + checkout_All.Checked.ToString() + " " + unzip;
                                startInfo.Arguments = arg_1;
                                // MessageBox.Show(ELCAD_ImportFromTC_CMD + " " + arg_1);
                                Process myProcess = Process.Start(startInfo);

                                myProcess.WaitForExit();

                                progressBar_CSV.PerformStep();
                                progressBar_CSV.Update();
                                progressBar_CSV.Refresh();

                                if (myProcess.ExitCode != 0)
                                {
                                    err_code = myProcess.ExitCode;
                                    err_msg += SAPMatNo + ";" + revision + " = " + err_code.ToString() + " ";
                                }
                            }
                        }
                    }
                    else
                    {
                        err_msg = "import CSV file not exist: " + selected_CSV_File;
                        err_code = 4;
                    }
                }
            }
            else
            {
                err_msg = "This function is n/a";
                err_code = 2;
            }

            if (err_code != 0)
            {
                label_working.Text = "Error";
                label_working.ForeColor = Color.Red;
                errorProvider1.SetError(comboBox_ExpImpTC, err_msg);
            }
            else
            {
                if (comboBox_ExpImpTC.SelectedIndex == 2)
                {
                    label_working.Text = "done " + Path.GetFileName(selected_CSV_File);
                    textBox_CSV.Text = string.Empty;
                    selected_CSV_File = String.Empty;
                    // leave the appliation open, not started from ELCAD!
                }
                else
                {
                    Close();
                }
            }
        }

        /// <summary>
        /// aux function
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        private string GetRootFolder(string path)
        {
            while (true)
            {
                string temp = Path.GetDirectoryName(path);
                if (String.IsNullOrEmpty(temp))
                    break;
                path = temp;
            }
            return path;
        }

        /// <summary>
        /// Get TC User from file with content: set "UPG=-u=TC-User -p=TC-Passw -g=..."
        /// </summary>
        /// <param name="login_file"></param>
        /// <returns>TC Login UserId</returns>
        private string GetTCUser(string login_file)
        {
            string returnUser = string.Empty;
            try
            {

                if (File.Exists(login_file))
                {
                    string content = File.ReadAllLines(login_file).First();
                    if (!string.IsNullOrEmpty(content))
                    {
                        string partString1 = content.Remove(0, 12);
                        if (!string.IsNullOrEmpty(partString1))
                        {
                            returnUser = partString1.Split(' ')[0];
                        }
                    }
                }
            }
            catch (Exception ex_gtu)
            {
                returnUser = string.Empty;
                errorProvider1.SetError(textBox_user, ex_gtu.Message);
            }
            return returnUser;
        }
        private string GetTCGroup(string login_file)
        {
            string returnGroup = string.Empty;
            try
            {

                if (File.Exists(login_file))
                {
                    string content = File.ReadAllLines(login_file).First();
                    if (!string.IsNullOrEmpty(content))
                    {
                        string partString1 = content.Remove(0, 12);
                        if (!string.IsNullOrEmpty(partString1))
                        {
                            string returnGroupComplete = partString1.Split(' ')[2];
                            returnGroup = returnGroupComplete.Split('=')[1].TrimEnd('"');
                        }
                    }
                }
            }
            catch (Exception ex_gtu)
            {
                returnGroup = string.Empty;
                errorProvider1.SetError(textBox_user, ex_gtu.Message);
            }
            return returnGroup;
        }

        /// <summary>
        /// Write Header of mapping file to set the ELCAD Item Rev Attribute
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        private int WriteAttrFile(string path)
        {
            int return_code = 0;
            File.WriteAllText(path, "#|#" + Environment.NewLine);
            File.AppendAllText(path, "#01#" + Environment.NewLine);
            File.AppendAllText(path, "ITEM.object_type|ITEM.item_id|REV.item_revision_id|REV.pm5_dr_cad_system|REV.pm5_dr_cad_migrated_source" + Environment.NewLine);
            File.AppendAllText(path, "ITEM.object_type|ITEM.item_id|REV.item_revision_id|REV.pm5_dr_cad_system|REV.pm5_dr_cad_migrated_source" + Environment.NewLine);
            File.AppendAllText(path, "STRING|STRING|STRING|STRING|STRING" + Environment.NewLine);
            File.AppendAllText(path, "||||" + Environment.NewLine);
            File.AppendAllText(path, "#### Mapping Values ####" + Environment.NewLine);
            // File.AppendAllText(path, "PM5_Eng_Design|" + ItemId + "|"+ ItemRev + "|E-CAD|ELCAD" + Environment.NewLine);

            return return_code;
        }

        /// <summary>
        /// 0: electrical
        /// 1: hydraulical
        /// 2: unknown
        /// </summary>
        /// <param name="elcad_type"></param>
        /// <returns></returns>
        private int mapping_elcad_type_input(string elcad_type)
        {
            int return_type = 0;
            if (string.IsNullOrEmpty(elcad_type)) return 2;

            elcad_type = elcad_type.ToLower();
            switch (elcad_type)
            {
                case "hy-plan":
                    return_type = 1;
                    break;
                case "ks":
                    return_type = 0;
                    break;
                default:
                    return_type = 2;
                    string err_msg = "Input ELCAD Type not handled: " + elcad_type;
                    errorProvider1.SetError(comboBox_ExpImpTC, err_msg);
                    //MessageBox.Show(err_msg);// string.Join(",", arguments));
                    break;
            }

            return return_type;
        }
        /// <summary>
        /// ELCAD_EL (Electro-Plan), 
        /// ELCAD_HY (Hydraulic-Plan)
        /// </summary>
        /// <param name="elcad_type"></param>
        /// <returns></returns>
        private string mapping_elcad_selection(int elcad_type)
        {
            string return_type = string.Empty;
            if (elcad_type > 2) return "";

            switch (elcad_type)
            {
                case 0:
                    return_type = "ELCAD_EL";
                    break;
                case 1:
                    return_type = "ELCAD_HY";
                    break;
                default:
                    return_type = "ELCAD_unknown";
                    break;
            }

            return return_type;
        }

        private void button_cancel_Click(object sender, EventArgs e)
        {
            //File.Delete(TC_Login_file);
            File.Delete(TC_SAP_MN);
            Close();
        }

        private void textBox_Passw_TextChanged(object sender, EventArgs e)
        {
            if (!(string.IsNullOrEmpty(textBox_user.Text) || string.IsNullOrEmpty(textBox_Passw.Text)))
            {
                // index 0 and 1 are valid ELCAD types
                if (comboBox_ELCAD_Type.SelectedIndex <= 1) { 
                    button_OK.Enabled = true;
                }
            }
        }

        private void textBox_group_TextChanged(object sender, EventArgs e)
        {

        }


        private void textBox_user_TextChanged(object sender, EventArgs e)
        {
            if (!(string.IsNullOrEmpty(textBox_user.Text) || string.IsNullOrEmpty(textBox_Passw.Text)))
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
            /*
            DialogResult result = folderBrowserProject.ShowDialog();
            if (result == DialogResult.OK)
            {
                textBox_SelProj.Text = folderBrowserProject.SelectedPath;
                selected_Exp2TC_Proj = Path.GetFileName(textBox_SelProj.Text);
                //MessageBox.Show(selected_Exp2TC_Proj, "Debug");
            }
            */
            DialogResult result = openProjectDialog.ShowDialog();
            if (result == DialogResult.OK)
            {
                textBox_SelProj.Text = openProjectDialog.FileName;
                selected_Exp2TC_Proj = Path.GetFileNameWithoutExtension(textBox_SelProj.Text);
                ELCAD_ExportToTC_ZIP = openProjectDialog.FileName;
            }
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            // 0:Import from TC; 1: Export to TC
            if (comboBox_ExpImpTC.SelectedIndex == 1)
            {
                groupBox_Imp.Enabled = false;
                groupBox_Imp.Visible = true;
                groupBox_Exp.Enabled = true;
                groupBox_ImpList.Enabled = false;
                groupBox_ImpList.Visible = false;
                groupBox_ImpList.Enabled = false;
                groupBox_ImpList.Visible = false;
            }
            else if (comboBox_ExpImpTC.SelectedIndex == 0)
            {
                groupBox_Imp.Enabled = true;
                groupBox_Imp.Visible = true;
                groupBox_Exp.Enabled = false;
                groupBox_ImpList.Enabled = false;
                groupBox_ImpList.Visible = false;
            }
            else if (comboBox_ExpImpTC.SelectedIndex == 2)
            {
                groupBox_Imp.Enabled = false;
                groupBox_Exp.Enabled = false;
                groupBox_Imp.Visible = false;
                groupBox_ImpList.Visible = true;
                groupBox_ImpList.Enabled = true;
            }

        }

        private void comboBox_ELCAD_Type_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (comboBox_ELCAD_Type.SelectedIndex > 1)
            {
                button_OK.Enabled = false;
            }
            else
            {
                button_OK.Enabled = true;
            }
        }

        private void label_group_Click(object sender, EventArgs e)
        {

        }

        private void label_password_Click(object sender, EventArgs e)
        {

        }

        private void textBox_SAP_Rev_TextChanged(object sender, EventArgs e)
        {

        }

        private void button_SelCSV_Click(object sender, EventArgs e)
        {
            DialogResult result = openCSVDialog.ShowDialog();
            if (result == DialogResult.OK)
            {
                textBox_CSV.Text = openCSVDialog.FileName;
                //selected_CSV_File = Path.GetFileNameWithoutExtension(textBox_CSV.Text);
                selected_CSV_File = textBox_CSV.Text;
            }
        }

        private void textBox_CSV_TextChanged(object sender, EventArgs e)
        {
            // Import List
            if (comboBox_ExpImpTC.SelectedIndex == 2)
            {
                if (!string.IsNullOrEmpty(textBox_CSV.Text))
                {
                    string selected_CSV_File = Path.GetFullPath(textBox_CSV.Text);
                    if (File.Exists(selected_CSV_File))
                    {
                        button_OK.Enabled = true;
                    }
                    else
                    {
                        button_OK.Enabled = false;
                    }
                }
                else
                {
                    button_OK.Enabled = false;
                }
            }
        }
    }
}
