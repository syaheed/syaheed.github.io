from openai import OpenAI
import json

with open('openapi_key.txt') as f:  # just to put the key in a seperate file. Should be just a blank text file with "sk-??????"
    key = f.read()
client = OpenAI(api_key=key) # or just replace "key" with the api-key "sk-??????"

#model_choice = "gpt-3.5-turbo"
model_choice = "gpt-3.5-turbo-1106" # just to pick from the different models. Suggest debugging on the cheapest model to use
#model_choice = "gpt-4"
#model_choice = "gpt-4-1106-preview"

max_tokens_choice = 2048 
message_memory = 15 # how many messages to keep in mind for context (system prompt, the next 2 messages, and then the rest are from the end)
temperature_choice = 0.7 #parameter for the model
seed_choice = 1337 # not sure what this does since the generated response is still different with the same seed. 
save_filename = "./output.json" # enables saving and loading across sessions.

# The system prompt will govern the behaviour of the openAI model. This is an example of an AI that generates scenes.
sys_prompt = 'You are an expert novel author, specialising in thrillers. For each prompt, craft a scene starting with the given prompt and concluding where the prompt ends. Your scene should unfold with vivid detail, encompassing the senses and the immediate environment to enrich the setting. Characters must converse in a manner that reflects their unique personalities, using clever and witty dialogue that naturally conveys the required information. Include gestures, expressions, and interactions that bring the scene to life. Ensure the dialogue is snappy and contributes to the scene without progressing beyond the initial scenario. Maintain a focus on creating an immersive experience within the confines of the present moment described in the prompt. Try to respond with at least 700 words. Do not end scenes unless the user specifies it.'
msg_htx = [{"role": "system", "content": sys_prompt}]
print()

def add_prompt(prompt):
    msg_htx.append( {'role': 'user', 'content': prompt})
    msg_sel =  msg_htx
    mlen = len(msg_htx)
    if mlen > message_memory:
        for m in range(mlen-message_memory):
            msg_sel.pop(3) # remove the 4th message until you only get to the desired number of messages in history chosen
    stream = client.chat.completions.create(model=model_choice, messages=msg_htx, max_tokens=max_tokens_choice, stream=True, temperature=temperature_choice, seed=seed_choice)
    print()
    reply = ''
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            ch = chunk.choices[0].delta.content
            print(ch, end="")
            reply = reply + ch     
    msg_htx.append( {'role': 'assistant', 'content': reply})
    print()
    print()
    
def load_stream(msg_htx_file):
    with open(msg_htx_file, "r") as read_file:
        msg_htx = json.load(read_file)
        return(msg_htx)
    
def save_stream(msg_htx_file):
    with open(msg_htx_file, 'w') as fout:
        json.dump(msg_htx , fout)

while True:
    prompt = input("User: ")
    if prompt.lower() == "quit": #quit without saving
        break
    elif prompt.lower() == "save": #save function, to json
        save_stream(save_filename)    
        print("Message history has been saved.")
        print()
    elif prompt.lower() == "load":
        msg_htx = load_stream(save_filename) #load function, from a json   
        print("Message history has been loaded.")
        print()
    elif prompt.lower() == "undo": #undo the previous response and the prompt for it
        msg_htx.pop(-1)
        msg_htx.pop(-1)
        print('Previous prompt and reply has been removed')
        print()
    elif prompt.lower() == "redo": #regenerate the response given the same previous prompt
        msg_htx.pop(-1)
        temp = msg_htx[-1]
        msg_htx.pop(-1)
        add_prompt(temp['content'])       
    elif prompt.lower() == "last": #print the last response given
        print(msg_htx[-1]['content'])
        print()          
    elif prompt.lower() == "init": #a canned initial prompt, useful for debugging
        add_prompt("Dr. Xavier Kang is a scientist who has invented a new form of computing. It is set to revolutionise the entire computing landscape from servers to workstations to laptops to tablets to mobile phones. Companies are in a mad dash to buy out the tech, but Xavier prefers to launch the device himself. Xavier is asked for many interviews but he turns them all down. Describe this scene where Xavier goes through his e-mails in detail.")
    else:
        add_prompt(prompt)

print("Ending session.")


