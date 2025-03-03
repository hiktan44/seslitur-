package com.example.sesliiletisim

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

/**
 * LoginActivity - Kullanıcı giriş ekranı
 * 
 * Bu aktivite, kullanıcının email ve şifre bilgileriyle sisteme giriş yapmasını sağlar.
 * Ayrıca admin girişi seçeneği de mevcuttur.
 */
class LoginActivity : AppCompatActivity() {
    
    private lateinit var emailEditText: EditText
    private lateinit var passwordEditText: EditText
    private lateinit var loginButton: Button
    private lateinit var forgotPasswordTextView: TextView
    private lateinit var errorTextView: TextView
    private lateinit var adminSwitch: Switch
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)
        
        // UI bileşenlerini tanımla
        emailEditText = findViewById(R.id.emailEditText)
        passwordEditText = findViewById(R.id.passwordEditText)
        loginButton = findViewById(R.id.loginButton)
        forgotPasswordTextView = findViewById(R.id.forgotPasswordTextView)
        errorTextView = findViewById(R.id.errorTextView)
        adminSwitch = findViewById(R.id.adminSwitch)
        
        // Buton tıklama olaylarını ayarla
        loginButton.setOnClickListener {
            loginUser()
        }
        
        forgotPasswordTextView.setOnClickListener {
            navigateToForgotPassword()
        }
    }
    
    /**
     * Kullanıcı giriş işlemi
     */
    private fun loginUser() {
        val email = emailEditText.text.toString().trim()
        val password = passwordEditText.text.toString().trim()
        val isAdmin = adminSwitch.isChecked
        
        // Giriş bilgilerini doğrula
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
        
        // Demo amaçlı admin girişi (gerçek uygulamada API istekleri kullanılacak)
        if (isAdmin) {
            if (email == "admin@example.com" && password == "12345") {
                navigateToAdminDashboard()
            } else {
                showError("Admin giriş bilgileri hatalı")
            }
        } 
        // Normal kullanıcı girişi
        else {
            // Demo için basit bir kontrol
            if (email == "user@example.com" && password == "12345") {
                navigateToDashboard()
            } else {
                showError("Giriş bilgileri hatalı")
            }
        }
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
    
    /**
     * Şifremi unuttum ekranına yönlendirme
     */
    private fun navigateToForgotPassword() {
        // Intent ile ForgotPasswordActivity'ye geçiş
        // val intent = Intent(this, ForgotPasswordActivity::class.java)
        // startActivity(intent)
    }
    
    /**
     * Dashboard ekranına yönlendirme
     */
    private fun navigateToDashboard() {
        // Intent ile DashboardActivity'ye geçiş
        // val intent = Intent(this, DashboardActivity::class.java)
        // startActivity(intent)
        // finish() // Login ekranına geri dönüşü engelle
        
        Toast.makeText(this, "Giriş başarılı!", Toast.LENGTH_SHORT).show()
    }
    
    /**
     * Admin paneline yönlendirme
     */
    private fun navigateToAdminDashboard() {
        // Intent ile AdminDashboardActivity'ye geçiş
        // val intent = Intent(this, AdminDashboardActivity::class.java)
        // startActivity(intent)
        // finish() // Login ekranına geri dönüşü engelle
        
        Toast.makeText(this, "Admin girişi başarılı!", Toast.LENGTH_SHORT).show()
    }
} 