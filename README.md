# GPT3-AHK
An [AutoHotKey](https://www.autohotkey.com/) script that enables you to use [GPT3](https://beta.openai.com/docs/models/gpt-3) and other LLM models in any input field on your computer.

![demo](https://user-images.githubusercontent.com/2355491/208573555-bb764bc9-2694-4db7-8c74-7250439ae105.gif)

## Installation and configuration

1. Install [AutoHotKey](https://www.autohotkey.com/)
2. Download the repository as a ZIP file and uncompress it in a folder of your choice
3. Generate an OpenAI API key following [this instruction](https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key)
4. Execute GPT3-AHK.ahk and input your API key in the input box that will appear
5. In case you want to use a custom model compatible with OpenAI API (e.g. [litellm](https://github.com/BerriAI/litellm)), click Yes in the next box and add (if necessary) the API key in the following input box

## How to use

- To complete a phrase, select it and press `Win+o`
- To instruct GPT3 to modify a phrase, select it and press `Win+Shift+o`
- To change the model, right click on the icon at the taskbar and use the option `Select LLM` to select the desired model
- For custom models, change the `CUSTOM_MODEL_ENDPOINT` and `CUSTOM_MODEL_ID` variables to respectively point out to your server IP and to your desired model name.
