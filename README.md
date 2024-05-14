# Vercel Support DNS debug scripts

> [!TIP]
> Reach out to the Vercel Support here: [vercel.com/help](https://vercel.com/help)

If you're having trouble connecting to your Vercel deployment, you might be asked by our support engineers to run these debug commands.

Run the below mentioned command, depending on your operating system, from a terminal of your choice. This script will conduct various checks, and depending on different factors, it may take anywhere from 5 to 15 minutes to complete and will create a `vercel-debug.txt` file in the current working directory, which you then can attach to your open support case with Vercel Support.


## Commands to run:

### Mac/Linux (Bash/ZSH):
    curl -s https://raw.githubusercontent.com/vercel-support/vercel-connect-debug/main/vercel-debug.sh | bash | tee vercel-debug.txt

### Windows 10/11 (Powershell): 
    Invoke-RestMethod -Uri https://raw.githubusercontent.com/vercel-support/vercel-connect-debug/main/vercel-debug.ps1 | Invoke-Expression | tee vercel-debug.txt
