package com.example.sesliiletisim

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.Button
import android.widget.CheckBox
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

/**
 * RegisterActivity - Yeni kullanıcı kayıt ekranı
 * 
 * Bu aktivite, yeni kullanıcıların sisteme kaydolmasını sağlar.
 * İsim, e-posta, şifre ve şifre onayı alanları içerir ve kullanım şartlarının kabul edilmesini ister.
 */
class RegisterActivity : AppCompatActivity() {
    
    private lateinit var nameEditText: EditText
    private lateinit var emailEditText: EditText
    private lateinit var passwordEditText: EditText
    private lateinit var confirmPasswordEditText: EditText
    private lateinit var termsCheckBox: CheckBox
    private lateinit var termsTextView: TextView
    private lateinit var registerButton: Button
    private lateinit var errorTextView: TextView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)
        
        // UI bileşenlerini tanımla
        nameEditText = findViewById(R.id.nameEditText)
        emailEditText = findViewById(R.id.emailEditText)
        passwordEditText = findViewById(R.id.passwordEditText)
        confirmPasswordEditText = findViewById(R.id.confirmPasswordEditText)
        termsCheckBox = findViewById(R.id.termsCheckBox)
        termsTextView = findViewById(R.id.termsTextView)
        registerButton = findViewById(R.id.registerButton)
        errorTextView = findViewById(R.id.errorTextView)
        
        // Buton tıklama olaylarını ayarla
        registerButton.setOnClickListener {
            registerUser()
        }
        
        termsTextView.setOnClickListener {
            showTermsDialog()
        }
    }
    
    /**
     * Kullanıcı kayıt işlemi
     */
    private fun registerUser() {
        val name = nameEditText.text.toString().trim()
        val email = emailEditText.text.toString().trim()
        val password = passwordEditText.text.toString().trim()
        val confirmPassword = confirmPasswordEditText.text.toString().trim()
        val termsAccepted = termsCheckBox.isChecked
        
        // Kayıt bilgilerini doğrula
        if (TextUtils.isEmpty(name)) {
            showError("İsim gerekli")
            return
        }
        
        if (TextUtils.isEmpty(email)) {
            showError("E-posta adresi gerekli")
            return
        }
        
        if (!isValidEmail(email)) {
            showError("Geçerli bir e-posta adresi girin")
            return
        }
        
        if (TextUtils.isEmpty(password)) {
            showError("Şifre gerekli")
            return
        }
        
        if (password.length < 6) {
            showError("Şifre en az 6 karakter olmalıdır")
            return
        }
        
        if (password != confirmPassword) {
            showError("Şifreler eşleşmiyor")
            return
        }
        
        if (!termsAccepted) {
            showError("Kullanım şartlarını kabul etmelisiniz")
            return
        }
        
        // Kayıt işlemini gerçekleştir (gerçek uygulamada API çağrısı yapılacak)
        Toast.makeText(this, "Kayıt başarılı! Giriş yapabilirsiniz.", Toast.LENGTH_LONG).show()
        finish() // RegisterActivity'yi kapat ve önceki ekrana dön
    }
    
    /**
     * Kullanım şartları diyaloğunu göster
     */
    private fun showTermsDialog() {
        val builder = AlertDialog.Builder(this)
        builder.setTitle("Kullanım Şartları")
        builder.setMessage(
            "1. Bu uygulama, gerçek zamanlı sesli iletişim sağlar.\n\n" +
            "2. Paylaşılan içeriklerden kullanıcılar sorumludur.\n\n" +
            "3. Diğer kullanıcılara saygılı olunması beklenir.\n\n" +
            "4. Kişisel verileriniz gizlilik politikamız kapsamında korunur."
        )
        builder.setPositiveButton("Anladım") { dialog, _ ->
            dialog.dismiss()
        }
        builder.show()
    }
    
    /**
     * Hata mesajını göster
     */
    private fun showError(message: String) {
        errorTextView.text = message
        errorTextView.visibility = View.VISIBLE
    }
    
    /**
     * E-posta formatı doğrulama
     */
    private fun isValidEmail(email: String): Boolean {
        return android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()
    }
} 