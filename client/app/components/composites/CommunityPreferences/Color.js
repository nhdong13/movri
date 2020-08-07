import React, { Component } from 'react';
import { SketchPicker } from 'react-color'

class Color extends Component {
  constructor(props) {
    super(props)
    this.state = {
      colorEnabledFor: "",
    }
    this.colorPickToggle = this.colorPickToggle.bind(this)
    this.handleColorClose = this.handleColorClose.bind(this)
    this.handleChangeGeneralColor = this.handleChangeGeneralColor.bind(this)
    this.handleChangeFooterColor = this.handleChangeFooterColor.bind(this)
    this.handleChangeButtonColor = this.handleChangeButtonColor.bind(this)
    this.handleChangeHeaderColor = this.handleChangeHeaderColor.bind(this)
  }

  colorPickToggle(value) {
    this.setState({ colorEnabledFor: value === this.state.colorEnabledFor ? "" : value})
  }

  handleColorClose() {
    this.setState({ colorEnabledFor: "" })
  }

  handleChangeButtonColor(name, color) {
    let button_colors = this.props.preferences.button_colors || {}
    button_colors[name] = color.hex
    let preferences = {...this.props.preferences, button_colors: button_colors }
    this.props.handleChangePreferences(preferences)
  }

  handleChangeGeneralColor(name, color) {
    let general_colors = this.props.preferences.general_colors || {}
    general_colors[name] = color.hex
    let preferences = {...this.props.preferences, general_colors: general_colors }
    this.props.handleChangePreferences(preferences)
  }

  handleChangeFooterColor(name, color) {
    let footer_colors = this.props.preferences.footer_colors || {}
    footer_colors[name] = color.hex
    let preferences = {...this.props.preferences, footer_colors: footer_colors }
    this.props.handleChangePreferences(preferences)
  }

  handleChangeHeaderColor(name, color) {
    let header_colors = this.props.preferences.header_colors || {}
    header_colors[name] = color.hex
    let preferences = {...this.props.preferences, header_colors: header_colors }
    this.props.handleChangePreferences(preferences)
  }

  render() {
    const styles = {
      cover: {
        position: 'fixed',
        top: '0px',
        right: '0px',
        bottom: '0px',
        left: '0px',
      }
    }
    let preferences = this.props.preferences || {}
    let general_colors = preferences.general_colors || {}
    let footer_colors = preferences.footer_colors || {}
    let button_colors = preferences.button_colors || {}
    let header_colors = preferences.header_colors || {}
    return (
      <div className="section row">
        <label className="m-1">Colors</label>
        <div className="section-wrapper col-8 m-1 row">
          <div className="col-5">
            <div className="sub-section col-12 mb-3">
              <label className="p-1">GENERAL</label>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: general_colors["background"] || "#ffffff"}}
                    onClick={() => this.colorPickToggle("general_backgound")}>
                </button>
                <div>Background</div>
                {this.state.colorEnabledFor === "general_backgound" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ general_colors["background"] }
                      onChangeComplete={(color) => this.handleChangeGeneralColor("background", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: general_colors["headings"] || "#000000"}}
                    onClick={() => this.colorPickToggle("general_headings")}>
                </button>
                <div>Headings</div>
                {this.state.colorEnabledFor === "general_headings"  && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ general_colors["headings"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeGeneralColor("headings", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: general_colors["text"] || "#000000"}}
                    onClick={() => this.colorPickToggle("general_text")}>
                </button>
                <div>Text</div>
                {this.state.colorEnabledFor === "general_text"  && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ general_colors["text"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeGeneralColor("text", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: general_colors["links"] || "#000000"}}
                    onClick={() => this.colorPickToggle("general_links")}>
                </button>
                <div>Links</div>
                {this.state.colorEnabledFor === "general_links"  && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ general_colors["links"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeGeneralColor("links", color) }
                    />
                  </div>
                }
              </div>
            </div>
            <div className="sub-section col-12 mb-3">
              <label className="p-1">FOOTER</label>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: footer_colors["background"] || "#ffffff"}}
                    onClick={() => this.colorPickToggle("footer_backgound")}>
                </button>
                <div>Background</div>
                {this.state.colorEnabledFor === "footer_backgound" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ footer_colors["background"] || "#ffffff" }
                      onChangeComplete={(color) => this.handleChangeFooterColor("background", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: footer_colors["text"] || "#000000"}}
                    onClick={() => this.colorPickToggle("footer_text")}>
                </button>
                <div>Text</div>
                {this.state.colorEnabledFor === "footer_text" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ footer_colors["text"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeFooterColor("text", color) }
                    />
                  </div>
                }
              </div>
            </div>
          </div>
          <div className="col-5">
            <div className="sub-section col-12 mb-3">
              <label className="p-1">BUTTONS</label>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: button_colors["background"] || "#ffffff"}}
                    onClick={() => this.colorPickToggle("button_backgound")}>
                </button>
                <div>Background</div>
                {this.state.colorEnabledFor === "button_backgound" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ button_colors["background"] || "#ffffff" }
                      onChangeComplete={(color) => this.handleChangeButtonColor("background", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: button_colors["text"] || "#000000"}}
                    onClick={() => this.colorPickToggle("button_text")}>
                </button>
                <div>Text</div>
                {this.state.colorEnabledFor === "button_text" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ button_colors["text"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeButtonColor("text", color) }
                    />
                  </div>
                }
              </div>
            </div>
            <div className="sub-section col-12 mb-3">
              <label className="p-1">HEADER</label>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: header_colors["background"] || "#ffffff"}}
                    onClick={() => this.colorPickToggle("header_backgound")}>
                </button>
                <div>Background</div>
                {this.state.colorEnabledFor === "header_backgound" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ header_colors["background"] || "#ffffff" }
                      onChangeComplete={(color) => this.handleChangeHeaderColor("background", color) }
                    />
                  </div>
                }
              </div>
              <div className='form-control p-1'>
                <button
                    type='button'
                    className='color-box mr-2'
                    style={{backgroundColor: header_colors["text"] || "#000000"}}
                    onClick={() => this.colorPickToggle("header_text")}>
                </button>
                <div>Text</div>
                {this.state.colorEnabledFor === "header_text" && 
                  <div>
                    <div style={ styles.cover } onClick={ this.handleColorClose }/>
                    <SketchPicker
                      color={ header_colors["text"] || "#000000" }
                      onChangeComplete={(color) => this.handleChangeHeaderColor("text", color) }
                    />
                  </div>
                }
              </div>
            </div>
          </div>
        </div>
      </div>
   );
 }
}

export default Color;