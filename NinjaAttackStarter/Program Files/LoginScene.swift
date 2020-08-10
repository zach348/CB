import SpriteKit
import UIKit
import Firebase
protocol TransitionDelegate: SKSceneDelegate {
  func showAlert(title:String,message:String,handlers:[String:() -> Void])
  func handleLoginBtn(username:String,password:String)
  func handleCreateBtn(username:String,password:String)
}
class LoginScene: SKScene,UITextFieldDelegate {
    weak var gameViewController:GameViewController?
    var usernameTextField:UITextField!
    var passwordTextField:UITextField!
    var loginBtn:SKShapeNode!
    var createBtn:SKShapeNode!
    var forgotPasswordLabel:SKLabelNode = SKLabelNode()

    override func didMove(to view: SKView) {
        //bg
        let background = SKSpriteNode(imageNamed: "sphere-gray")
        background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        background.size = CGSize(width: self.frame.width/2, height: self.frame.height/2)
        addChild(background)
        //title
        let title = SKLabelNode.init(fontNamed: "AppleSDGothicNeo-Bold")
        title.text = "Kalibrate"; title.fontSize = 25
        title.fontColor = .cyan
        addChild(title)
        title.zPosition = 1
        title.position = CGPoint(x:self.size.width/2,y:self.size.height-80)
        //textfields
        guard let view = self.view else { return }
        let originX = (view.frame.size.width - view.frame.size.width/1.5)/2
        usernameTextField = UITextField(frame: CGRect.init(x: originX, y: view.frame.size.height/4.5, width: view.frame.size.width/1.5, height: 30))
        customize(textField: usernameTextField, placeholder: "Enter your email")
        view.addSubview(usernameTextField)
        usernameTextField.addTarget(self, action:#selector(LoginScene.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordTextField = UITextField(frame: CGRect.init(x: originX, y: view.frame.size.height/4.5+60, width: view.frame.size.width/1.5, height: 30))
        customize(textField: passwordTextField, placeholder: "Enter your password", isSecureTextEntry:true)
        view.addSubview(passwordTextField)
        //buttons
        loginBtn = getButton(frame: CGRect(x:self.size.width/4,y:self.size.height/2.5,width:self.size.width/2,height:30),fillColor: SKColor.blue,title:"Login",logo:nil,name:"loginBtn")
        createBtn = getButton(frame: CGRect(x:self.size.width/4,y:self.size.height/2.5 - 40,width:self.size.width/2,height:30),fillColor: SKColor.blue,title:"Create Account",logo:nil,name:"createBtn")
        forgotPasswordLabel.text = "Forgot Password?"
        forgotPasswordLabel.name = "forgotPasswordLabel"
        forgotPasswordLabel.fontSize = 15
        forgotPasswordLabel.fontColor = SKColor.white
        forgotPasswordLabel.fontName = "Arial"
        forgotPasswordLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/11)
        addChild(loginBtn)
        addChild(forgotPasswordLabel)
        addChild(createBtn)
        loginBtn.zPosition = 1
        createBtn.zPosition = 1
    
    }
    func customize(textField:UITextField, placeholder:String , isSecureTextEntry:Bool = false) {
        let paddingView = UIView(frame:CGRect(x:0,y: 0,width: 10,height: 30))
        textField.leftView = paddingView
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.leftViewMode = UITextField.ViewMode.always
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 4.0
        textField.textColor = .white
        textField.isSecureTextEntry = isSecureTextEntry
        textField.delegate = self
    }
    func getButton(frame:CGRect,fillColor:SKColor,title:String = "",logo:SKSpriteNode!,name:String)->SKShapeNode {
        let btn = SKShapeNode(rect: frame, cornerRadius: 10)
        btn.fillColor = fillColor
        btn.strokeColor = fillColor
        if let l = logo {
            btn.addChild(l)
            l.zPosition = 2
            l.position = CGPoint(x:frame.origin.x+(frame.size.width/2),y:frame.origin.y+(frame.size.height/2))
            l.name = name
        }
        if !title.isEmpty {
            let label = SKLabelNode.init(fontNamed: "AppleSDGothicNeo-Regular")
            label.text = title; label.fontSize = 15
            label.fontColor = .white
            btn.addChild(label)
            label.zPosition = 3
            label.position = CGPoint(x:frame.origin.x+(frame.size.width/2),y:frame.origin.y+(frame.size.height/4))
            label.name = name
        }
        btn.name = name
        return btn
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.endEditing(true)
        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)

        if let name = touchedNode.name {
            switch name {
                case "loginBtn":
                    self.run(SKAction.wait(forDuration: 0.1),completion:{[unowned self] in
                        guard let delegate = self.delegate else { return }
                        (delegate as! TransitionDelegate).handleLoginBtn(username:self.usernameTextField.text!,password: self.passwordTextField.text!)
                    })
                case "createBtn":
                  self.run(SKAction.wait(forDuration: 0.1),completion:{[unowned self] in
                      guard let delegate = self.delegate else { return }
                      (delegate as! TransitionDelegate).handleCreateBtn(username:self.usernameTextField.text!,password: self.passwordTextField.text!)
                  })
                case "forgotPasswordLabel":
                  guard let gameViewController = self.gameViewController else {break}
                  let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                  let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                  let emailValid = emailTest.evaluate(with: self.usernameTextField.text)
                  if emailValid {
                    Auth.auth().sendPasswordReset(withEmail: self.usernameTextField.text!, completion: { error in
                      if let error = error {
                        gameViewController.showAlert(title: "Password Reset Error", message: error.localizedDescription)
                      }else{
                        gameViewController.showAlert(title: "Password Reset Sent", message: "If an account exists, a password reset link has been sent to \(self.usernameTextField.text!)")
                      }
                    })
                  }else{
                    gameViewController.showAlert(title: "Invalid Email", message: "Please enter a valid email in username field and try again")
                  }
              
                default:
                  break
            }
        }
    }
  @objc func textFieldDidChange(textField: UITextField) {
        //print("everytime you type something this is fired..")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameTextField { // validate email syntax
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: textField.text)
            let title = "Invalid Email"
            let message = result ? "This is a correct email" : "Invalid email syntax"
            if !result {
                self.run(SKAction.wait(forDuration: 0.01),completion:{[unowned self] in
                    guard let delegate = self.delegate else { return }
                  (delegate as! TransitionDelegate).showAlert(title:title,message: message,handlers: ["Ok": {}])
                })
            }
        }
    }
    deinit {
      usernameTextField.removeFromSuperview()
      passwordTextField.removeFromSuperview()
      print("\n THE SCENE \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}
