/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'App'
import { quillEditor } from 'vue-quill-editor'
import axios from 'axios'
jest.mock('axios')

describe('App.vue', () => {
  it('renders a form', () => {
    const wrapper = shallowMount(App, {
    })
    expect(wrapper.findAll('form')).toHaveLength(1)
  })

  describe('Tab Navigation', () => {
    beforeEach(() => {
      const wrapper = shallowMount(App, {
      })

      wrapper.vm.$data.sharedState.tabs.about_me.complete = false
      wrapper.vm.$data.sharedState.tabs.my_program.complete = false
      wrapper.vm.$data.sharedState.tabs.my_advisor.complete = false
      wrapper.vm.$data.sharedState.tabs.my_etd.complete = false
      wrapper.vm.$data.sharedState.tabs.keywords.complete = false
      wrapper.vm.$data.sharedState.tabs.my_files.complete = false
      wrapper.vm.$data.sharedState.tabs.embargo.complete = false

      wrapper.vm.$data.sharedState.tabs.about_me.currentStep = true
      wrapper.vm.$data.sharedState.tabs.my_program.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_advisor.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_etd.currentStep = false
      wrapper.vm.$data.sharedState.tabs.keywords.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_files.currentStep = false
      wrapper.vm.$data.sharedState.tabs.embargo.currentStep = false

      wrapper.vm.$data.sharedState.loadTabs()
    });

    it('enables the completed and current tabs', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.sharedState.savedData['currentStep'] = 1
      wrapper.vm.$data.sharedState.tabs.about_me.complete = true
      wrapper.vm.$data.sharedState.tabs.my_program.complete = true
      wrapper.vm.$data.sharedState.tabs.my_advisor.currentStep = true
      wrapper.vm.$data.sharedState.currentStep = 1
      wrapper.vm.$data.sharedState.loadTabs()

      expect(wrapper.vm.$data.sharedState.tabs.about_me.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_program.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_advisor.disabled).toBe(false)

      wrapper.vm.$data.sharedState.savedData['currentStep'] = undefined
    })

    it('can set the complete property of a tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.sharedState.setComplete('About Me')

      expect(wrapper.vm.$data.sharedState.tabs.about_me.complete).toBe(true)
    })

    it('sets the current tab property', () => {
      const wrapper = shallowMount(App, {
      })
      // user has completed About Me tab, and My Program is current tab
      wrapper.vm.$data.sharedState.savedData['currentStep'] = 1
      wrapper.vm.$data.sharedState.tabs.about_me.complete = true
      wrapper.vm.$data.sharedState.tabs.about_me.currentStep = false
      wrapper.vm.$data.sharedState.tabs.my_program.currentStep = true
      wrapper.vm.$data.sharedState.loadTabs()
      expect(wrapper.vm.$data.sharedState.tabs.about_me.currentStep).toBe(false)

      //find and click first tab
      wrapper.find('button.tab').trigger('click')

      expect(wrapper.vm.$data.sharedState.tabs.about_me.currentStep).toBe(true)
      wrapper.vm.$data.sharedState.savedData['currentStep'] = undefined
    })

    it('prevents a user from navigating to disabled tabs', () => {
      const wrapper = shallowMount(App, {
      })
      //find and click first disabled element (My Program)
      wrapper.find('button.tab.disabled').trigger('click')

      expect(wrapper.find('h1').text()).toBe('Submit Your Thesis or Dissertation')
    })
    it("displays all of the user's data on the submit tab", () => {
      const wrapper = shallowMount(App, {
      })
    })
    it('lets the user submit their data for publication as an ETD', () => {

    })
  })

  describe('Tabs reflect saved progress', () => {
    beforeEach(() => {
      const wrapper = shallowMount(App, {
      })
      // simulate completion of first two tabs
      wrapper.vm.$data.sharedState.savedData['currentStep'] = 1
    })

    it('displays the 3rd tab if the saved currentStep = 2nd', () => {
      const wrapper = shallowMount(App, {
      })
      expect(wrapper.vm.$data.sharedState.tabs.about_me.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_program.disabled).toBe(false)
      expect(wrapper.vm.$data.sharedState.tabs.my_advisor.disabled).toBe(false)

      expect(wrapper.vm.$data.sharedState.tabs.my_etd.disabled).toBe(true)
      expect(wrapper.vm.$data.sharedState.tabs.keywords.disabled).toBe(true)
      expect(wrapper.vm.$data.sharedState.tabs.my_files.disabled).toBe(true)
      expect(wrapper.vm.$data.sharedState.tabs.embargo.disabled).toBe(true)

      expect(wrapper.vm.$data.sharedState.tabs.my_advisor.currentStep).toBe(true)
    })

  })

  describe('Edit form:', () => {
    it('with an associated ETD record, renders the form without tabs', () => {
      const wrapper = shallowMount(App, { })
      wrapper.vm.$data.sharedState.setEtdId('123')
      expect(wrapper.html()).toContain('Submit Your Thesis')
      expect(wrapper.findAll('ul.navtabs').length).toEqual(0)
      expect(wrapper.html()).toContain('<useragreement-stub></useragreement-stub>')
      expect(wrapper.html()).not.toContain('<submit-stub></submit-stub>')
    })

    it('without an associated ETD record, renders the form with tabs', () => {
      const wrapper = shallowMount(App, { })
      wrapper.vm.$data.sharedState.setEtdId(undefined)
      expect(wrapper.html()).toContain('Submit Your Thesis')
      expect(wrapper.findAll('ul.navtabs').length).toEqual(1)
      expect(wrapper.html()).not.toContain('<useragreement-stub></useragreement-stub>')
      expect(wrapper.html()).not.toContain('<submit-stub></submit-stub>')
    })
  })
})
