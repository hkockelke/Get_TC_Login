
namespace Get_TC_Login
{
    partial class Form1
    {
        /// <summary>
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Windows Form-Designer generierter Code

        /// <summary>
        /// Erforderliche Methode für die Designerunterstützung.
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.label_user = new System.Windows.Forms.Label();
            this.textBox_user = new System.Windows.Forms.TextBox();
            this.label_password = new System.Windows.Forms.Label();
            this.textBox_Passw = new System.Windows.Forms.TextBox();
            this.label_group = new System.Windows.Forms.Label();
            this.textBox_group = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.textBox_SAP_MN = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.textBox_SAP_Rev = new System.Windows.Forms.TextBox();
            this.checkout = new System.Windows.Forms.CheckBox();
            this.button_OK = new System.Windows.Forms.Button();
            this.button_cancel = new System.Windows.Forms.Button();
            this.groupBox_Imp = new System.Windows.Forms.GroupBox();
            this.folderBrowserProject = new System.Windows.Forms.FolderBrowserDialog();
            this.textBox_SelProj = new System.Windows.Forms.TextBox();
            this.button_selProj = new System.Windows.Forms.Button();
            this.errorProvider1 = new System.Windows.Forms.ErrorProvider(this.components);
            this.groupBox_Exp = new System.Windows.Forms.GroupBox();
            this.comboBox_ExpImpTC = new System.Windows.Forms.ComboBox();
            this.groupBox_Imp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.errorProvider1)).BeginInit();
            this.groupBox_Exp.SuspendLayout();
            this.SuspendLayout();
            // 
            // label_user
            // 
            this.label_user.AutoSize = true;
            this.label_user.Location = new System.Drawing.Point(40, 42);
            this.label_user.Name = "label_user";
            this.label_user.Size = new System.Drawing.Size(46, 13);
            this.label_user.TabIndex = 0;
            this.label_user.Text = "TC User";
            this.label_user.Click += new System.EventHandler(this.label_user_Click);
            // 
            // textBox_user
            // 
            this.textBox_user.Location = new System.Drawing.Point(139, 38);
            this.textBox_user.Name = "textBox_user";
            this.textBox_user.Size = new System.Drawing.Size(157, 20);
            this.textBox_user.TabIndex = 1;
            this.textBox_user.TextChanged += new System.EventHandler(this.textBox_user_TextChanged);
            // 
            // label_password
            // 
            this.label_password.AutoSize = true;
            this.label_password.Location = new System.Drawing.Point(40, 86);
            this.label_password.Name = "label_password";
            this.label_password.Size = new System.Drawing.Size(70, 13);
            this.label_password.TabIndex = 2;
            this.label_password.Text = "TC Password";
            this.label_password.Click += new System.EventHandler(this.label_password_Click);
            // 
            // textBox_Passw
            // 
            this.textBox_Passw.Location = new System.Drawing.Point(139, 82);
            this.textBox_Passw.Name = "textBox_Passw";
            this.textBox_Passw.Size = new System.Drawing.Size(156, 20);
            this.textBox_Passw.TabIndex = 3;
            this.textBox_Passw.TextChanged += new System.EventHandler(this.textBox_Passw_TextChanged);
            // 
            // label_group
            // 
            this.label_group.AutoSize = true;
            this.label_group.Location = new System.Drawing.Point(40, 132);
            this.label_group.Name = "label_group";
            this.label_group.Size = new System.Drawing.Size(53, 13);
            this.label_group.TabIndex = 4;
            this.label_group.Text = "TC Group";
            this.label_group.Click += new System.EventHandler(this.label_group_Click);
            // 
            // textBox_group
            // 
            this.textBox_group.Location = new System.Drawing.Point(139, 128);
            this.textBox_group.Name = "textBox_group";
            this.textBox_group.Size = new System.Drawing.Size(157, 20);
            this.textBox_group.TabIndex = 5;
            this.textBox_group.TextChanged += new System.EventHandler(this.textBox_group_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(38, 28);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(48, 13);
            this.label1.TabIndex = 6;
            this.label1.Text = "SAP MN";
            // 
            // textBox_SAP_MN
            // 
            this.textBox_SAP_MN.Location = new System.Drawing.Point(137, 24);
            this.textBox_SAP_MN.Name = "textBox_SAP_MN";
            this.textBox_SAP_MN.Size = new System.Drawing.Size(154, 20);
            this.textBox_SAP_MN.TabIndex = 7;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(38, 80);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(51, 13);
            this.label2.TabIndex = 8;
            this.label2.Text = "SAP Rev";
            // 
            // textBox_SAP_Rev
            // 
            this.textBox_SAP_Rev.Location = new System.Drawing.Point(137, 75);
            this.textBox_SAP_Rev.Name = "textBox_SAP_Rev";
            this.textBox_SAP_Rev.Size = new System.Drawing.Size(22, 20);
            this.textBox_SAP_Rev.TabIndex = 9;
            // 
            // checkout
            // 
            this.checkout.AutoSize = true;
            this.checkout.Location = new System.Drawing.Point(137, 126);
            this.checkout.Name = "checkout";
            this.checkout.Size = new System.Drawing.Size(71, 17);
            this.checkout.TabIndex = 10;
            this.checkout.Text = "checkout";
            this.checkout.UseVisualStyleBackColor = true;
            // 
            // button_OK
            // 
            this.button_OK.Enabled = false;
            this.button_OK.Location = new System.Drawing.Point(38, 498);
            this.button_OK.Name = "button_OK";
            this.button_OK.Size = new System.Drawing.Size(53, 38);
            this.button_OK.TabIndex = 12;
            this.button_OK.Text = "OK";
            this.button_OK.UseVisualStyleBackColor = true;
            this.button_OK.Click += new System.EventHandler(this.button_OK_Click);
            // 
            // button_cancel
            // 
            this.button_cancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.button_cancel.Location = new System.Drawing.Point(181, 502);
            this.button_cancel.Name = "button_cancel";
            this.button_cancel.Size = new System.Drawing.Size(102, 33);
            this.button_cancel.TabIndex = 13;
            this.button_cancel.Text = "Cancel";
            this.button_cancel.UseVisualStyleBackColor = true;
            this.button_cancel.Click += new System.EventHandler(this.button_cancel_Click);
            // 
            // groupBox_Imp
            // 
            this.groupBox_Imp.Controls.Add(this.checkout);
            this.groupBox_Imp.Controls.Add(this.textBox_SAP_Rev);
            this.groupBox_Imp.Controls.Add(this.label2);
            this.groupBox_Imp.Controls.Add(this.textBox_SAP_MN);
            this.groupBox_Imp.Controls.Add(this.label1);
            this.groupBox_Imp.Location = new System.Drawing.Point(-2, 210);
            this.groupBox_Imp.Name = "groupBox_Imp";
            this.groupBox_Imp.Size = new System.Drawing.Size(342, 158);
            this.groupBox_Imp.TabIndex = 11;
            this.groupBox_Imp.TabStop = false;
            this.groupBox_Imp.Text = "ELCAD import from TC";
            // 
            // folderBrowserProject
            // 
            this.folderBrowserProject.Description = "ELCAD Project";
            this.folderBrowserProject.RootFolder = System.Environment.SpecialFolder.MyComputer;
            this.folderBrowserProject.SelectedPath = "C:\\plmtemp\\ELCAD";
            this.folderBrowserProject.HelpRequest += new System.EventHandler(this.folderBrowserProject_HelpRequest);
            // 
            // textBox_SelProj
            // 
            this.textBox_SelProj.Location = new System.Drawing.Point(135, 45);
            this.textBox_SelProj.Name = "textBox_SelProj";
            this.textBox_SelProj.Size = new System.Drawing.Size(177, 20);
            this.textBox_SelProj.TabIndex = 14;
            this.textBox_SelProj.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // button_selProj
            // 
            this.button_selProj.Location = new System.Drawing.Point(43, 42);
            this.button_selProj.Name = "button_selProj";
            this.button_selProj.Size = new System.Drawing.Size(52, 23);
            this.button_selProj.TabIndex = 16;
            this.button_selProj.Text = "SelProj";
            this.button_selProj.UseVisualStyleBackColor = true;
            this.button_selProj.Click += new System.EventHandler(this.button_selProj_Click);
            // 
            // errorProvider1
            // 
            this.errorProvider1.ContainerControl = this;
            // 
            // groupBox_Exp
            // 
            this.groupBox_Exp.Controls.Add(this.button_selProj);
            this.groupBox_Exp.Controls.Add(this.textBox_SelProj);
            this.groupBox_Exp.Location = new System.Drawing.Point(0, 374);
            this.groupBox_Exp.Name = "groupBox_Exp";
            this.groupBox_Exp.Size = new System.Drawing.Size(346, 94);
            this.groupBox_Exp.TabIndex = 17;
            this.groupBox_Exp.TabStop = false;
            this.groupBox_Exp.Text = "ELCAD export to TC";
            // 
            // comboBox_ExpImpTC
            // 
            this.comboBox_ExpImpTC.FormattingEnabled = true;
            this.comboBox_ExpImpTC.Items.AddRange(new object[] {
            "Import from TC",
            "Export to TC"});
            this.comboBox_ExpImpTC.Location = new System.Drawing.Point(139, 170);
            this.comboBox_ExpImpTC.Name = "comboBox_ExpImpTC";
            this.comboBox_ExpImpTC.Size = new System.Drawing.Size(156, 21);
            this.comboBox_ExpImpTC.TabIndex = 18;
            this.comboBox_ExpImpTC.SelectedIndexChanged += new System.EventHandler(this.comboBox1_SelectedIndexChanged);
            // 
            // Form1
            // 
            this.AcceptButton = this.button_OK;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.CancelButton = this.button_cancel;
            this.ClientSize = new System.Drawing.Size(340, 560);
            this.Controls.Add(this.comboBox_ExpImpTC);
            this.Controls.Add(this.groupBox_Exp);
            this.Controls.Add(this.groupBox_Imp);
            this.Controls.Add(this.button_cancel);
            this.Controls.Add(this.button_OK);
            this.Controls.Add(this.textBox_group);
            this.Controls.Add(this.label_group);
            this.Controls.Add(this.textBox_Passw);
            this.Controls.Add(this.label_password);
            this.Controls.Add(this.textBox_user);
            this.Controls.Add(this.label_user);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form1";
            this.Text = "TC Login";
            this.groupBox_Imp.ResumeLayout(false);
            this.groupBox_Imp.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.errorProvider1)).EndInit();
            this.groupBox_Exp.ResumeLayout(false);
            this.groupBox_Exp.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label_user;
        private System.Windows.Forms.TextBox textBox_user;
        private System.Windows.Forms.Label label_password;
        private System.Windows.Forms.TextBox textBox_Passw;
        private System.Windows.Forms.Label label_group;
        private System.Windows.Forms.TextBox textBox_group;
        private System.Windows.Forms.Button button_OK;
        private System.Windows.Forms.Button button_cancel;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox textBox_SAP_MN;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox textBox_SAP_Rev;
        private System.Windows.Forms.CheckBox checkout;
        private System.Windows.Forms.GroupBox groupBox_Imp;
        private System.Windows.Forms.FolderBrowserDialog folderBrowserProject;
        private System.Windows.Forms.TextBox textBox_SelProj;
        private System.Windows.Forms.Button button_selProj;
        private System.Windows.Forms.ErrorProvider errorProvider1;
        private System.Windows.Forms.GroupBox groupBox_Exp;
        private System.Windows.Forms.ComboBox comboBox_ExpImpTC;
    }
}

