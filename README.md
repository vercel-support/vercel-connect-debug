# Vercel Support DNS debug scripts

> [!TIP]
> Reach out to the Vercel Support here: [vercel.com/help](https://vercel.com/help)

If you're having trouble connecting to your Vercel deployment, you might be asked by our support engineers to run these debug commands.

Run the below mentioned command, depending on your operating system, from a terminal of your choice. This will roughly take about 5 minutes to complete and will create a `vercel-debug.txt` file in the current working directory, which you then can attach to your open support case with Vercel Support.


## Commands to run:

### Mac/Linux (Bash/ZSH):
    curl -s https://raw.githubusercontent.com/robachicken/test-ping/main/vercel-debug.sh | bash | tee vercel-debug.txt

### Windows (Powershell): 
    Invoke-RestMethod -Uri https://raw.githubusercontent.com/robachicken/test-ping/main/vercel-debug.ps1 | Invoke-Expression | tee vercel-debug.txt
