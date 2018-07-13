/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'App'
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
      wrapper.vm.$data.form.tabs.about_me.complete = false
      wrapper.vm.$data.form.tabs.my_program.complete = false
      wrapper.vm.$data.form.tabs.my_advisor.complete = false
      wrapper.vm.$data.form.tabs.my_etd.complete = false
      wrapper.vm.$data.form.tabs.keywords.complete = false
      wrapper.vm.$data.form.tabs.my_files.complete = false
      wrapper.vm.$data.form.tabs.embargo.complete = false

      wrapper.vm.$data.form.tabs.about_me.currentStep = true
      wrapper.vm.$data.form.tabs.my_program.currentStep = false
      wrapper.vm.$data.form.tabs.my_advisor.currentStep = false
      wrapper.vm.$data.form.tabs.my_etd.currentStep = false
      wrapper.vm.$data.form.tabs.keywords.currentStep = false
      wrapper.vm.$data.form.tabs.my_files.currentStep = false
      wrapper.vm.$data.form.tabs.embargo.currentStep = false

      wrapper.vm.enableTabs()
    });

    it('enables the completed and current tabs', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.form.tabs.about_me.complete = true
      wrapper.vm.$data.form.tabs.my_program.complete = true
      wrapper.vm.$data.form.tabs.my_advisor.currentStep = true

      wrapper.vm.enableTabs()

      expect(wrapper.vm.$data.form.tabs.about_me.disabled).toBe(false)
      expect(wrapper.vm.$data.form.tabs.my_program.disabled).toBe(false)
      expect(wrapper.vm.$data.form.tabs.my_advisor.disabled).toBe(false)
    })

    it('can set the complete property of a tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.setComplete('About Me')

      expect(wrapper.vm.$data.form.tabs.about_me.complete).toBe(true)
    })

    it('sets the current tab property', () => {
      const wrapper = shallowMount(App, {
      })
      // user has completed About Me tab, and My Program is current tab
      wrapper.vm.$data.form.tabs.about_me.complete = true
      wrapper.vm.$data.form.tabs.about_me.currentStep = false
      wrapper.vm.$data.form.tabs.my_program.currentStep = true
      wrapper.vm.enableTabs()
      expect(wrapper.vm.$data.form.tabs.about_me.currentStep).toBe(false)

      //find and click first tab
      wrapper.find('a.tab').trigger('click')

      expect(wrapper.vm.$data.form.tabs.about_me.currentStep).toBe(true)
    })

    it('determines the next current tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.nextStepIsCurrent(3)

      expect(wrapper.vm.$data.form.tabs.keywords.currentStep).toBe(true)
    })

    it('prevents a user from navigating to disabled tabs', () => {
      const wrapper = shallowMount(App, {
      })
      //find and click first disabled element (My Program)
      wrapper.find('a.tab.disabled').trigger('click')

      expect(wrapper.find('h1').text()).toBe('About Me');
    })
    it("displays all of the user's data on the submit tab", () => {
      const wrapper = shallowMount(App, {
      })
      //oof. oki, click submit and redirect to show page? or load show view into form area and let people scroll ... nah.
      //wrapper.find({name: "Submit"}).trigger('click')
      // expect show view
    })
    it('lets the user submit their data for publication as an ETD', () => {
      
    })
  })
})
