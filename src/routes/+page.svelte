<script lang="ts">
  import Editor from '../lib/Editor.svelte';
  import { invoke } from '@tauri-apps/api/core';
  import { open, save } from '@tauri-apps/plugin-dialog';

  let currentCode = `#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}`;

  let currentFilePath = '';
  let editorRef: Editor;
  let statusMessage = 'Ready';
  let isObfuscating = false;

  function handleCodeChange(newCode: string) {
    currentCode = newCode;
  }

  async function openFile() {
    try {
      const selected = await open({
        multiple: false,
        filters: [{
          name: 'C/C++ Files',
          extensions: ['c', 'cpp', 'cc', 'cxx', 'h', 'hpp']
        }]
      });

      if (selected) {
        currentFilePath = selected.path;
        const content = await invoke<string>('load_file', { 
          path: currentFilePath 
        });
        
        if (editorRef) {
          editorRef.setCode(content);
        }
        statusMessage = `Opened: ${currentFilePath}`;
      }
    } catch (error) {
      statusMessage = `Error: ${error}`;
      console.error('Open file failed:', error);
    }
  }

  async function saveFile() {
    try {
      let pathToSave = currentFilePath;
      
      if (!pathToSave) {
        const selected = await save({
          filters: [{
            name: 'C/C++ Files',
            extensions: ['cpp', 'c']
          }]
        });
        
        if (selected) {
          pathToSave = selected.path;
          currentFilePath = pathToSave;
        } else {
          return;
        }
      }

      await invoke('save_file', { 
        path: pathToSave, 
        content: currentCode 
      });
      
      statusMessage = `Saved: ${pathToSave}`;
    } catch (error) {
      statusMessage = `Error: ${error}`;
      console.error('Save failed:', error);
    }
  }

  async function obfuscateCode() {
    if (isObfuscating) return;
    
    try {
      isObfuscating = true;
      statusMessage = 'Obfuscating...';
      
      const obfuscated = await invoke<string>('obfuscate_code', { 
        code: currentCode 
      });
      
      if (editorRef) {
        editorRef.setCode(obfuscated);
      }
      
      statusMessage = 'Obfuscation complete';
    } catch (error) {
      statusMessage = `Obfuscation error: ${error}`;
      console.error('Obfuscation failed:', error);
    } finally {
      isObfuscating = false;
    }
  }

  async function compileCode() {
    try {
      statusMessage = 'Compiling...';
      
      const result = await invoke<string>('compile_code', {
        code: currentCode,
        outputPath: 'a.out'
      });
      
      statusMessage = result;
    } catch (error) {
      statusMessage = `Compilation error: ${error}`;
      console.error('Compilation failed:', error);
    }
  }

  // Keyboard shortcuts
  function handleKeydown(e: KeyboardEvent) {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault();
      saveFile();
    } else if ((e.ctrlKey || e.metaKey) && e.key === 'o') {
      e.preventDefault();
      openFile();
    } else if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'O') {
      e.preventDefault();
      obfuscateCode();
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />

<main>
  <div class="toolbar">
    <div class="toolbar-group">
      <button on:click={openFile} title="Open (Ctrl+O)">
        📂 Open
      </button>
      <button on:click={saveFile} title="Save (Ctrl+S)">
        💾 Save
      </button>
    </div>
    
    <div class="toolbar-group">
      <button 
        on:click={obfuscateCode} 
        disabled={isObfuscating}
        title="Obfuscate (Ctrl+Shift+O)"
        class="primary"
      >
        {isObfuscating ? '⏳ Obfuscating...' : '🔒 Obfuscate'}
      </button>
      <button on:click={compileCode} title="Compile">
        ⚙️ Compile
      </button>
    </div>
  </div>

  <div class="editor-container">
    <Editor 
      bind:this={editorRef}
      code={currentCode}
      onChange={handleCodeChange}
    />
  </div>

  <div class="statusbar">
    <span>{statusMessage}</span>
    <span class="file-info">
      {currentFilePath || 'Untitled'} | {currentCode.length} chars
    </span>
  </div>
</main>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    overflow: hidden;
  }

  main {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
    background: #1e1e1e;
    color: #d4d4d4;
  }

  .toolbar {
    display: flex;
    justify-content: space-between;
    padding: 8px;
    background: #252526;
    border-bottom: 1px solid #3e3e42;
  }

  .toolbar-group {
    display: flex;
    gap: 8px;
  }

  button {
    padding: 6px 12px;
    background: #3e3e42;
    color: #cccccc;
    border: 1px solid #3e3e42;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
    font-family: system-ui, -apple-system, sans-serif;
    transition: all 0.2s;
  }

  button:hover:not(:disabled) {
    background: #505050;
    border-color: #505050;
  }

  button:active:not(:disabled) {
    transform: translateY(1px);
  }

  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  button.primary {
    background: #0e639c;
    border-color: #0e639c;
  }

  button.primary:hover:not(:disabled) {
    background: #1177bb;
    border-color: #1177bb;
  }

  .editor-container {
    flex: 1;
    overflow: hidden;
    position: relative;
  }

  .statusbar {
    display: flex;
    justify-content: space-between;
    padding: 4px 12px;
    background: #007acc;
    color: white;
    font-size: 12px;
    font-family: system-ui, -apple-system, sans-serif;
  }

  .file-info {
    opacity: 0.9;
  }
</style>