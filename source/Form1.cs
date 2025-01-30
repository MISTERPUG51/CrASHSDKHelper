using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Security.Policy;
using System.Text;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace CrASH_SDK_Helper
{
    public partial class Form1 : Form
    {
        public string currentFile = "";
        private void SaveAs()
        {
            saveFileDialog1.ShowDialog();
            currentFile = saveFileDialog1.FileName;
            if (System.IO.Path.GetFileNameWithoutExtension(currentFile).Length > 8)
            {
                MessageBox.Show("The file name (not including the extension) must be less than 8 characters. The CrASH SDK does not work properly with file names with more than 8 characters.", caption: "Error: Filename too long", MessageBoxButtons.OK, MessageBoxIcon.Error);
                SaveAs();
            } else
            {
                this.Text = "CrASH SDK Helper - " + currentFile;
                System.IO.File.WriteAllText(currentFile, richTextBox1.Text);
                saveToolStripMenuItem.Enabled = true;
            }
        }

        private void Save()
        {
            this.Text = "CrASH SDK Helper - " + currentFile;
            System.IO.File.WriteAllText(currentFile, richTextBox1.Text);
        }
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            openFileDialog1.FileName = "";
            saveToolStripMenuItem.Enabled = false;
        }

        private void cRASHTXTToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Process.Start("notepad.exe", "CrASHSDK/CRASH.TXT");
        }

        private void cRASHPRGTXTToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Process.Start("notepad.exe", "CrASHSDK/CRASHPRG.TXT");
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void menuStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("This will discard any unsaved changes in the currently open file. Do you still want to continue?", "Warning", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                richTextBox1.Text = "";
                currentFile = "";
                this.Text = "CrASH SDK Helper - Unsaved";
                saveToolStripMenuItem.Enabled = false;
            }
        }

        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Save();
            
        }

        private void saveAsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveAs();
        }

        private void aSMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("http://karma.ticalc.org/guide/contents.html");
        }

        private void compileProgramToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Compile();
        }

        private void richTextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("CrASH SDK Helper 1.0\n\n©2025 MISTERPUG51\n\nThe license and other information can be found on the Github repository.\nDo you want to open the Github repository?", caption: "About", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                Process.Start("https://github.com/MISTERPUG51/CrASHSDKHelper");
            }


        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            openFileDialog1.ShowDialog();
            currentFile = openFileDialog1.FileName;
            if (System.IO.Path.GetFileNameWithoutExtension(currentFile).Length > 8)
            {
                MessageBox.Show("The file name (not including the extension) must be less than 8 characters. Rename the file and try opening it again. The CrASH SDK does not work properly with file names with more than 8 characters.", caption: "Error: Filename too long", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
            {
                this.Text = "CrASH SDK Helper - " + currentFile;
                richTextBox1.Text = "Loading " + currentFile;
                richTextBox1.Text = System.IO.File.ReadAllText(currentFile);
                saveToolStripMenuItem.Enabled = true;
            }
        }

        private void importAincludeFileINCToolStripMenuItem_Click(object sender, EventArgs e)
        {
            openFileDialog1.Title = "Select a .INC file to import.";
            openFileDialog1.Filter = ".INC Files|*.inc";
            openFileDialog1.ShowDialog();
            openFileDialog1.Filter = "Assembly Files|*.asm";
            openFileDialog1.Title = "Select an assembly file to open.";
            System.IO.File.Copy(openFileDialog1.FileName, AppDomain.CurrentDomain.BaseDirectory + openFileDialog1.SafeFileName);
            MessageBox.Show("File successfully imported. The imported file is located at:\n" + AppDomain.CurrentDomain.BaseDirectory + openFileDialog1.SafeFileName);
        }

        private void visitWebsiteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("https://misterpug51.github.io/lnk/crashsdkhelper/");
        }

        private void visitGithubRepositoryToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Process.Start("https://github.com/MISTERPUG51/crashsdkhelper/");
        }

        public void Compile()
        {
            if (currentFile == "")
            {
                MessageBox.Show("You need to save this file before you can compile it.");
            }
            else
            {
                DialogResult dialogResult = MessageBox.Show("All changes must be saved in order to compile your program. Do you want to save and compile your program?", "Do you want to save?", MessageBoxButtons.YesNo);
                if (dialogResult == DialogResult.Yes)
                {
                    Save();
                    MessageBox.Show("Choose or create a file to save your compiled program to.");
                    saveFileDialog1.Title = "Chose or create an 82P file to save your compiled program to.";
                    saveFileDialog1.Filter = "TI-82 Program File|*.82P";
                    saveFileDialog1.ShowDialog();
                    saveFileDialog1.Filter = "Assembly Files|*.asm";
                    saveFileDialog1.Title = "Chose or create a file to save your program to.";
                    string outputFile = saveFileDialog1.FileName;
                    string currentdir = AppDomain.CurrentDomain.BaseDirectory;
                    string asmFileInCrashFolder = currentdir + "/" + System.IO.Path.GetFileName(currentFile);
                    if (System.IO.File.Exists(asmFileInCrashFolder))
                    {
                        System.IO.File.Delete(asmFileInCrashFolder);
                    }
                    System.IO.File.Copy(currentFile, asmFileInCrashFolder);
                    System.Environment.CurrentDirectory = currentdir;

                    if (System.IO.File.Exists(System.IO.Path.GetDirectoryName(asmFileInCrashFolder) + "/" + System.IO.Path.GetFileNameWithoutExtension(asmFileInCrashFolder) + ".82p"))
                    {
                        System.IO.File.Delete(System.IO.Path.GetDirectoryName(asmFileInCrashFolder) + "/" + System.IO.Path.GetFileNameWithoutExtension(asmFileInCrashFolder) + ".82p");
                    }


                    var process = new Process();
                    process.StartInfo = new ProcessStartInfo
                    {
                        FileName = '"' + currentdir + "\\CRASM.BAT" + '"',
                        Arguments = System.IO.Path.GetFileNameWithoutExtension(asmFileInCrashFolder),
                        UseShellExecute = false,
                        RedirectStandardOutput = true,
                        RedirectStandardError = true
                    };

                    process.Start();
                    process.WaitForExit();

                    if (System.IO.File.Exists(System.IO.Path.GetDirectoryName(asmFileInCrashFolder) + "/" + System.IO.Path.GetFileNameWithoutExtension(asmFileInCrashFolder) + ".82p"))
                    {
                        if (System.IO.File.Exists(outputFile))
                        {
                            System.IO.File.Delete(outputFile);
                        }
                        System.IO.File.Copy(System.IO.Path.GetDirectoryName(asmFileInCrashFolder) + "/" + System.IO.Path.GetFileNameWithoutExtension(asmFileInCrashFolder) + ".82p", outputFile);
                        MessageBox.Show("The program was successfully compiled.\n\nThe .82P file for your program is:\n" + outputFile, caption: "Success!");
                    }
                    else
                    {
                        DialogResult dialogresult1 = MessageBox.Show("One or more errors occured during compilation. Do you want to see the error information?", caption: "Error", MessageBoxButtons.YesNo, MessageBoxIcon.Error);
                        if (dialogresult1 == DialogResult.Yes)
                        {
                            MessageBox.Show("CrASH SDK Output:\n" + process.StandardOutput.ReadToEnd() + "\n" + process.StandardError.ReadToEnd(), caption: "Error information");
                        }
                    }


                }
            }
        }

        private void viewReadmeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Process.Start("readme.txt");
        }
    }
}
