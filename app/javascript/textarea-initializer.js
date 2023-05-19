import CSRF from 'csrf'
import MarkDownItContainerDetails from 'markdown-it-container-details'
import MarkDownItContainerMessage from 'markdown-it-container-message'
import MarkDownItContainerSpeak from 'markdown-it-container-speak'
import MarkDownItLinkAttributes from 'markdown-it-link-attributes'
import MarkdownItEmoji from 'markdown-it-emoji'
import MarkdownItMention from 'markdown-it-mention'
import MarkdownItTaskLists from 'markdown-it-task-lists'
import MarkdownItUserIcon from 'markdown-it-user-icon'
import MarkdownOption from 'markdown-it-option'
import TextareaAutocomplteEmoji from 'textarea-autocomplte-emoji'
import TextareaAutocomplteMention from 'textarea-autocomplte-mention'
import TextareaMarkdown from 'textarea-markdown'
import Tribute from 'tributejs'
import UserIconRenderer from 'user-icon-renderer'
import autosize from 'autosize'

export default class {
  static initialize(selector) {
    const textareas = document.querySelectorAll(selector)
    if (textareas.length === 0) {
      return null
    }

    // autosize
    autosize(textareas)
    textareas.forEach((textarea) => {
      new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.target.scrollHeight !== 0) {
            autosize.update(entry.target)
          }
        })
      }).observe(textarea)
    })

    // auto-completion
    const emoji = new TextareaAutocomplteEmoji()
    const mention = new TextareaAutocomplteMention()

    mention.fetchValues((json) => {
      emoji.addUserData(json)
      mention.values = json
      mention.values.unshift({ login_name: 'mentor', name: 'メンター' })
      const collection = [emoji.params(), mention.params()]
      const tribute = new Tribute({
        collection: collection
      })
      tribute.attach(textareas)
    })

    // markdown
    Array.from(textareas).forEach((textarea) => {
      /* eslint-disable no-new */
      new TextareaMarkdown(textarea, {
        endPoint: '/api/image.json',
        paramName: 'file',
        responseKey: 'url',
        csrfToken: CSRF.getToken(),
        placeholder: '%filenameをアップロード中...',
        afterPreview: () => {
          autosize.update(textarea)

          const event = new Event('input', {
            bubbles: true,
            cancelable: true
          })
          textarea.dispatchEvent(event)
        },
        plugins: [
          MarkdownItEmoji,
          MarkdownItMention,
          MarkdownItUserIcon,
          MarkdownItTaskLists,
          MarkDownItContainerMessage,
          MarkDownItContainerDetails,
          MarkDownItLinkAttributes,
          MarkDownItContainerSpeak
        ],
        markdownOptions: MarkdownOption
      })
      /* eslint-enable no-new */
    })

    // user-icon
    new UserIconRenderer().render(selector)
  }

  static uninitialize(selector) {
    const textareas = document.querySelectorAll(selector)
    textareas.forEach((textarea) => {
      const cloneTextarea = textarea.cloneNode(true)
      textarea.parentNode.replaceChild(cloneTextarea, textarea)
    })
  }
}
