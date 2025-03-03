package com.example.sesliiletisim

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * MainActivity - Uygulamanın ana giriş ekranı
 * 
 * Bu aktivite, kullanıcıyı karşılayan ilk ekrandır ve login/kayıt seçeneklerini gösterir.
 * Kullanıcı buradan giriş yapabilir veya yeni bir hesap oluşturabilir.
 */
class MainActivity : AppCompatActivity() {
    
    private lateinit var welcomeTextView: TextView
    private lateinit var loginButton: Button
    private lateinit var registerButton: Button
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // UI bileşenlerini tanımla
        welcomeTextView = findViewById(R.id.welcomeTextView)
        loginButton = findViewById(R.id.loginButton)
        registerButton = findViewById(R.id.registerButton)
        
        // Buton tıklama olaylarını ayarla
        loginButton.setOnClickListener {
            navigateToLogin()
        }
        
        registerButton.setOnClickListener {
            navigateToRegister()
        }
    }
    
    /**
     * Giriş ekranına yönlendirme
     */
    private fun navigateToLogin() {
        // Intent ile LoginActivity'ye geçiş
        // val intent = Intent(this, LoginActivity::class.java)
        // startActivity(intent)
    }
    
    /**
     * Kayıt ekranına yönlendirme
     */
    private fun navigateToRegister() {
        // Intent ile RegisterActivity'ye geçiş
        // val intent = Intent(this, RegisterActivity::class.java)
        // startActivity(intent)
    }
} 